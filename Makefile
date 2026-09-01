# Local entry points. CI runs the same commands, see .github/workflows/ci.yml.

HUGO_VERSION := $(shell cat .hugo-version)
BUILD_COMMIT := $(shell git rev-parse HEAD 2>/dev/null || echo dev)

export HUGO_PARAMS_BUILDCOMMIT = $(BUILD_COMMIT)

.PHONY: help dev build check clean version

help:
	@echo "dev      serve on http://localhost:1313, drafts and future dates included"
	@echo "build    production build into public/"
	@echo "check    build, then verify the CSP hash matches the served HTML"
	@echo "version  compare the local Hugo against .hugo-version"
	@echo "clean    remove build output and generated resources"

dev: version
	hugo server --buildDrafts --buildFuture --disableFastRender

build: version
	hugo --minify --gc --cleanDestinationDir

check: build
	./scripts/check-csp-hash.sh public

version:
	@have=$$(hugo version | sed -n 's/^hugo v\([0-9.]*\).*/\1/p'); \
	if [ "$$have" != "$(HUGO_VERSION)" ]; then \
	  echo "warning: local Hugo $$have, pinned $(HUGO_VERSION). Builds may differ from CI." >&2; \
	fi; \
	hugo version | grep -q extended || { echo "error: Hugo extended is required (Sass)." >&2; exit 1; }

clean:
	rm -rf public resources/_gen .hugo_build.lock
