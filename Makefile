SHELL := /bin/sh

HUGO ?= hugo
HUGO_MIN_VERSION := 0.155.3
HUGO_CACHE_DIR ?= $(CURDIR)/.hugo_cache
POST ?=
export POST

.DEFAULT_GOAL := help

.PHONY: help doctor new serve build test check

help:
	@printf '%s\n' \
		'Local blog writing commands:' \
		'  make doctor              Check that Hugo Extended is available' \
		'  make new POST=my-post     Create content/posts/my-post.md as a draft' \
		'  make serve               Preview drafts at http://localhost:1313/' \
		'  make build               Create the production site in public/' \
		'  make test                Test the local writing commands' \
		'  make check               Run tests and a production build'

doctor:
	@command -v "$(HUGO)" >/dev/null 2>&1 || { \
		printf '%s\n' 'Hugo was not found. Install Hugo Extended 0.155.3 or newer.' >&2; \
		exit 1; \
	}
	@version="$$($(HUGO) version)"; \
	case "$$version" in \
		*extended*) ;; \
		*) printf '%s\n' 'Hugo Extended is required, but the installed build is not Extended.' >&2; exit 1 ;; \
	esac; \
	actual=$$(printf '%s\n' "$$version" | sed -n 's/^hugo v\([0-9][0-9.]*\).*/\1/p'); \
	[ -n "$$actual" ] || { printf 'Unable to read the Hugo version from: %s\n' "$$version" >&2; exit 1; }; \
	awk -v actual="$$actual" -v required="$(HUGO_MIN_VERSION)" 'BEGIN { \
		split(actual, a, "."); split(required, r, "."); \
		for (i = 1; i <= 3; i++) { \
			if ((a[i] + 0) > (r[i] + 0)) exit 0; \
			if ((a[i] + 0) < (r[i] + 0)) exit 1; \
		} \
		exit 0 \
	}' || { printf 'Hugo %s or newer is required; found %s.\n' "$(HUGO_MIN_VERSION)" "$$actual" >&2; exit 1; }; \
	printf 'Hugo ready: %s\n' "$$version"

new: doctor
	@case "$$POST" in \
		'') printf '%s\n' 'Usage: make new POST=my-post' >&2; exit 2 ;; \
		*[!A-Za-z0-9._-]*) printf '%s\n' 'POST must contain only letters, numbers, dots, underscores, and hyphens.' >&2; exit 2 ;; \
	esac
	@"$(HUGO)" new content "posts/$$POST.md"

serve: doctor
	@"$(HUGO)" server --buildDrafts --navigateToChanged --cacheDir "$(HUGO_CACHE_DIR)"

build: doctor
	@"$(HUGO)" --gc --minify --cleanDestinationDir --cacheDir "$(HUGO_CACHE_DIR)"

test:
	@./tests/writing-tools.sh

check: test build
