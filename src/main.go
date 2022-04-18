package main

import (
	"fmt"
	"os"
	"os/exec"
	"net/http"
	// "time"
	"github.com/mackerelio/go-osstat/memory"
	"github.com/mackerelio/go-osstat/cpu"
	"github.com/gorilla/mux"
	"github.com/gorilla/handlers"
)

func main() {
	r := mux.NewRouter()

	r.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		cmd := "/bin/cat /etc/os-release |/bin/grep PRETTY_NAME|/usr/bin/awk -F '=' '{print $2}'"
		out, err := exec.Command("sh","-c",cmd).Output()
		osVersion := string(out)
		if err != nil {
			fmt.Printf("%s", err)
			osVersion = "unknown"
		}
		htmlCode := fmt.Sprintf("<h1>OS version is %s\n</h1>",osVersion)
		// dt := time. Now()
		// candidateInfo := fmt.Sprintf("<h1>Xendit - Trial - Gaurav Kumar - 12-04-2022 - %s</h1>",dt.Format("01-02-2006"))
		// htmlCode = htmlCode+candidateInfo
		// topCmd := "/usr/bin/top -n 1|head -2"
		// topOut, err := exec.Command("sh","-c",topCmd).Output()
		// cpuMemoryUsage := string(topOut)

		// if err != nil {
		// 	fmt.Printf("%s", err)
		// 	cpuMemoryUsage = "Error in fetching CPU/Memory usage"
		// }
		memory, err := memory.Get()
		if err != nil {
			fmt.Fprintf(os.Stderr, "%s\n", err)
			return
		}

		memoryTotal := int(memory.Total/1024)
		memoryUsed := int(memory.Used/1024)
		memoryCached := int(memory.Cached/1024)
		memoryFree := int(memory.Free/1024)

		memoryUsage := fmt.Sprintf("Memory Usage:</br>Total: %dK, Used: %dK, Cached: %dK, Free: %dk</br>", memoryTotal,memoryUsed,memoryCached,memoryFree)

		before, err := cpu.Get()
		if err != nil {
			fmt.Fprintf(os.Stderr, "%s\n", err)
			return
		}
		time.Sleep(time.Duration(1) * time.Second)
		after, err := cpu.Get()
		if err != nil {
			fmt.Fprintf(os.Stderr, "%s\n", err)
			return
		}
		total := float64(after.Total - before.Total)
		cpuUser := float64(after.User-before.User)/total*100
		cpuSystem := float64(after.System-before.System)/total*100
		cpuIdle := float64(after.Idle-before.Idle)/total*100

		cpuUsage := fmt.Sprintf("CPU Usage:</br>User: %f, System: %f, Idle: %f", cpuUser,cpuSystem,cpuIdle)

		cpuMemoryUsageHtlm := fmt.Sprintf("<h1>Current CPU/Memory Usage:</br></h1><b>%s</b></br><b>%s</b>",memoryUsage,cpuUsage)	
		htmlCode = htmlCode+cpuMemoryUsageHtlm

		
		fmt.Fprintf(w, htmlCode)
	})
	r.HandleFunc("/_healthz", func(w http.ResponseWriter, _ *http.Request) { fmt.Fprint(w, "ok") })
	loggedRouter := handlers.LoggingHandler(os.Stdout, r)

	http.ListenAndServe(":80", loggedRouter)
}
