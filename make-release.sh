#!/usr/bin/env bash

set -euo pipefail
# SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
[[ -n "${DEBUG:-}" ]] && set -x

log() { echo "$1" >&2; }
fail() { log "$1"; exit 1; }

if [ $# -ne 2 ]
then
    fail "Need servicename and tag arguments"
fi
SERVICE=$1
TAG=$2
REPO_PREFIX="556070338223.dkr.ecr.us-east-1.amazonaws.com"


if [[ "$TAG" != v* ]]; then
    fail "\$TAG must start with 'v', e.g. v0.1.0 (got: $TAG)"
fi

[ "$(uname -s)" == "Linux" ] && lsed() {
    sed "$@"
}

[ "$(uname -s)" == "Darwin" ] && lsed() {
    gsed "$@"
}

# update yaml
k8s_manifests_file="release/kubernetes-manifests.yaml"

image="$REPO_PREFIX/$SERVICE:$TAG"

pattern="^(\s*)image:\s.*$SERVICE(.*)(\s*)"
replace="\1image: $image\3"
lsed -i -r "s|$pattern|$replace|g" "${k8s_manifests_file}"
echo "Done"

# create git release / push to new branch
# git checkout -b "release/${TAG}"
git add "."
git commit --allow-empty -m "Release $TAG"
log "Pushing k8s manifests to ${TAG}..."
git tag "$TAG"
git push --set-upstream origin main
git push --tags

log "Successfully tagged release $TAG."
