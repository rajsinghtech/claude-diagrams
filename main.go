package main

import (
	"embed"
	"flag"
	"fmt"
	"io/fs"
	"log"
	"net/http"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
)

//go:embed public/*
var publicFS embed.FS

func main() {
	var (
		port  = flag.String("port", "8080", "Port to run the server on")
		host  = flag.String("host", "0.0.0.0", "Host to bind the server to")
		dev   = flag.Bool("dev", false, "Run in development mode (use Hugo server)")
		build = flag.Bool("build", false, "Build Hugo site before starting")
	)
	flag.Parse()

	if *dev {
		runHugoDev(*host, *port)
		return
	}

	if *build {
		if err := buildHugo(); err != nil {
			log.Fatalf("Failed to build Hugo site: %v", err)
		}
	}

	// Check if public directory exists in embedded files
	if _, err := publicFS.ReadDir("public"); err != nil {
		log.Println("Warning: public directory not found in embedded files. Run with -build flag to generate it.")
	}

	subFS, err := fs.Sub(publicFS, "public")
	if err != nil {
		log.Fatalf("Failed to create sub filesystem: %v", err)
	}

	fileServer := http.FileServer(http.FS(subFS))

	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		path := r.URL.Path

		// Try to serve the file directly
		file, err := subFS.Open(strings.TrimPrefix(path, "/"))
		if err == nil {
			file.Close()
			fileServer.ServeHTTP(w, r)
			return
		}

		// If path doesn't have extension, try adding .html
		if !strings.Contains(filepath.Base(path), ".") {
			htmlPath := strings.TrimSuffix(path, "/") + ".html"
			if htmlPath == "/.html" {
				htmlPath = "/index.html"
			}

			file, err := subFS.Open(strings.TrimPrefix(htmlPath, "/"))
			if err == nil {
				file.Close()
				r.URL.Path = htmlPath
				fileServer.ServeHTTP(w, r)
				return
			}

			// Try index.html in directory
			indexPath := strings.TrimSuffix(path, "/") + "/index.html"
			file, err = subFS.Open(strings.TrimPrefix(indexPath, "/"))
			if err == nil {
				file.Close()
				r.URL.Path = indexPath
				fileServer.ServeHTTP(w, r)
				return
			}
		}

		// Serve 404
		http.NotFound(w, r)
	})

	addr := fmt.Sprintf("%s:%s", *host, *port)
	log.Printf("Starting server on http://%s", addr)
	if err := http.ListenAndServe(addr, nil); err != nil {
		log.Fatalf("Server failed: %v", err)
	}
}

func runHugoDev(host, port string) {
	log.Println("Starting Hugo development server...")

	cmd := exec.Command("hugo", "server", "-D", "--bind", host, "--port", port)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	cmd.Stdin = os.Stdin

	if err := cmd.Run(); err != nil {
		log.Fatalf("Hugo server failed: %v", err)
	}
}

func buildHugo() error {
	log.Println("Building Hugo site...")

	cmd := exec.Command("hugo", "--gc", "--minify")
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr

	if err := cmd.Run(); err != nil {
		return fmt.Errorf("hugo build failed: %w", err)
	}

	log.Println("Hugo build completed successfully")
	return nil
}
