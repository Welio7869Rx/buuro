package main

import (
	"encoding/json"
	"fmt"
	"log"
	"math/rand"
	"net/http"
	"os"
	"path/filepath"
	"strings"
	"time"
)

type WordEntry struct {
	Word      string `json:"word"`
	Hint      string `json:"hint"`
	Category  string `json:"category"`
	Difficulty string `json:"difficulty"`
}

type DB struct {
	Words []WordEntry `json:"words"`
}

func loadDB() (DB, error) {
	var db DB
	p := filepath.Join(".", "palavras-db.json")
	f, err := os.ReadFile(p)
	if err != nil {
		return db, err
	}
	if err := json.Unmarshal(f, &db); err != nil {
		return db, err
	}
	return db, nil
}

func withCors(h http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Access-Control-Allow-Origin", "*")
		w.Header().Set("Access-Control-Allow-Methods", "GET, OPTIONS")
		w.Header().Set("Access-Control-Allow-Headers", "Content-Type")
		if r.Method == "OPTIONS" {
			w.WriteHeader(http.StatusOK)
			return
		}
		h(w, r)
	}
}

func main() {
	rand.Seed(time.Now().UnixNano())
	db, err := loadDB()
	if err != nil {
		log.Printf("Aviso: não foi possível carregar palavras: %v\n", err)
	}

	http.HandleFunc("/api/words", withCors(func(w http.ResponseWriter, r *http.Request) {
		q := r.URL.Query()
		d := strings.ToLower(q.Get("difficulty"))
		if d == "" {
			json.NewEncoder(w).Encode(db)
			return
		}
		var out DB
		for _, e := range db.Words {
			if strings.ToLower(e.Difficulty) == d {
				out.Words = append(out.Words, e)
			}
		}
		json.NewEncoder(w).Encode(out)
	}))

	http.HandleFunc("/api/word", withCors(func(w http.ResponseWriter, r *http.Request) {
		q := r.URL.Query()
		d := strings.ToLower(q.Get("difficulty"))
		candidates := db.Words
		if d != "" {
			var filtered []WordEntry
			for _, e := range db.Words {
				if strings.ToLower(e.Difficulty) == d {
					filtered = append(filtered, e)
				}
			}
			if len(filtered) > 0 {
				candidates = filtered
			}
		}
		if len(candidates) == 0 {
			w.WriteHeader(http.StatusNotFound)
			w.Write([]byte("{\"error\":\"no words available\"}"))
			return
		}
		pick := candidates[rand.Intn(len(candidates))]
		json.NewEncoder(w).Encode(pick)
	}))

	http.HandleFunc("/api/hint", withCors(func(w http.ResponseWriter, r *http.Request) {
		q := r.URL.Query()
		word := strings.ToUpper(q.Get("word"))
		for _, e := range db.Words {
			if strings.ToUpper(e.Word) == word {
				json.NewEncoder(w).Encode(map[string]string{"hint": e.Hint})
				return
			}
		}
		w.WriteHeader(http.StatusNotFound)
		json.NewEncoder(w).Encode(map[string]string{"error": "not found"})
	}))

	// Serve static project files (optional)
	http.Handle("/", http.FileServer(http.Dir(".")))

	port := "8080"
	fmt.Printf("Servidor iniciado na porta %s\n", port)
	log.Fatal(http.ListenAndServe(":"+port, nil))
}
