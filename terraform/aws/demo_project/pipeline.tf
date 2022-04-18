resource "buddy_pipeline" "event_push" {
  domain         = "gauravjgec"
  project_name   = "demo"
  name           = "event_push"
  on             = "EVENT"
  priority       = "HIGH"
  fetch_all_refs = true

  event {
    type = "PUSH"
    refs = ["refs/heads/main"]
  }
}