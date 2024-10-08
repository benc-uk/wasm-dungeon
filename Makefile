GAME_BASE_PATH ?= ./
.DEFAULT_GOAL := help

help: ## This help message
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(firstword $(MAKEFILE_LIST)) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

build-bin: ## Build binaries for linux and windows
	env GOOS=linux GOARCH=amd64 go build -o bin/dungeon roguelike/game
	env GOOS=windows GOARCH=amd64 go build -o bin/dungeon.exe roguelike/game

build: build-wasm ## Build as WASM for web, and copy assets

build-wasm: ## Build as WASM for web, and copy assets
	env GOOS=js GOARCH=wasm go build -o web/main.wasm -ldflags="-X 'main.basePath=$(GAME_BASE_PATH)'" roguelike/game
	rm -rf web/assets
	cp -r assets/ web/

watch: ## Watch for changes and rebuild as local binary
	air -c .air.toml

lint: ## Check for linting problems
	golangci-lint run -E gofmt

format: ## Format the code
	gofmt -l -w .

serve: build-wasm ## Serve the web app
	npx vite 

watch-wasm: build-wasm ## Hot rebuild WASM binary in web directory
	air -c .air-wasm.toml --build.bin "true"

site: clean build-wasm ## Build/bundle the site for deployment
	mkdir -p site/
	cp -r ./web/* ./site

clean: ## Clean up
	rm -rf bin/ web/main.wasm site/ web/assets site/
	find . -name ".vite" -type d -exec rm -rf {} \; || true

localwin: clean build-bin
	rm -rf /mnt/c/Temp/roguelike/assets
	rm -rf /mnt/c/Temp/roguelike/*
	cp -r assets/ /mnt/c/Temp/roguelike
	cp bin/dungeon.exe /mnt/c/Temp/roguelike
