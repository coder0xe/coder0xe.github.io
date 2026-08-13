#!/bin/sh

set -eu

REPO_ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
TEST_ROOT=$(mktemp -d "${TMPDIR:-/tmp}/blog-writing-tools.XXXXXX")
HUGO_LOG="$TEST_ROOT/hugo.log"
FAKE_HUGO="$TEST_ROOT/hugo"
HUGO_VERSION_OUTPUT='hugo v0.155.3+extended darwin/arm64'

cleanup() {
    rm -f -- \
        "$HUGO_LOG" \
        "$FAKE_HUGO" \
        "$TEST_ROOT/invalid-post.out" \
        "$TEST_ROOT/missing-post.out" \
        "$TEST_ROOT/old-hugo.out" \
        "$TEST_ROOT/standard-hugo.out"
    rmdir -- "$TEST_ROOT"
}
trap cleanup EXIT HUP INT TERM

export HUGO_LOG HUGO_VERSION_OUTPUT

cat >"$FAKE_HUGO" <<'EOF'
#!/bin/sh
set -eu

printf '%s\n' "$*" >>"$HUGO_LOG"

if [ "${1:-}" = "version" ]; then
    printf '%s\n' "$HUGO_VERSION_OUTPUT"
fi
EOF
chmod +x "$FAKE_HUGO"

fail() {
    printf 'FAIL: %s\n' "$1" >&2
    exit 1
}

assert_log() {
    expected=$1
    actual=$(cat "$HUGO_LOG")
    [ "$actual" = "$expected" ] || fail "expected Hugo calls:\n$expected\nactual Hugo calls:\n$actual"
}

cd "$REPO_ROOT"

: >"$HUGO_LOG"
make --no-print-directory HUGO="$FAKE_HUGO" doctor >/dev/null
assert_log 'version'

HUGO_VERSION_OUTPUT='hugo v0.155.2+extended darwin/arm64'
if make --no-print-directory HUGO="$FAKE_HUGO" doctor >"$TEST_ROOT/old-hugo.out" 2>&1; then
    fail 'make doctor must reject Hugo versions older than 0.155.3'
fi

HUGO_VERSION_OUTPUT='hugo v0.155.3 darwin/arm64'
if make --no-print-directory HUGO="$FAKE_HUGO" doctor >"$TEST_ROOT/standard-hugo.out" 2>&1; then
    fail 'make doctor must require Hugo Extended'
fi

HUGO_VERSION_OUTPUT='hugo v0.155.3+extended darwin/arm64'

: >"$HUGO_LOG"
make --no-print-directory HUGO="$FAKE_HUGO" new POST=hello-world >/dev/null
assert_log 'version
new content posts/hello-world.md'

if make --no-print-directory HUGO="$FAKE_HUGO" new >"$TEST_ROOT/missing-post.out" 2>&1; then
    fail 'make new must reject a missing POST value'
fi

if make --no-print-directory HUGO="$FAKE_HUGO" new POST='nested/post' >"$TEST_ROOT/invalid-post.out" 2>&1; then
    fail 'make new must reject an unsafe POST value'
fi

: >"$HUGO_LOG"
make --no-print-directory HUGO="$FAKE_HUGO" serve >/dev/null
assert_log "version
server --buildDrafts --navigateToChanged --cacheDir $REPO_ROOT/.hugo_cache"

: >"$HUGO_LOG"
make --no-print-directory HUGO="$FAKE_HUGO" build >/dev/null
assert_log "version
--gc --minify --cleanDestinationDir --cacheDir $REPO_ROOT/.hugo_cache"

printf '%s\n' 'Writing tool smoke tests passed.'
