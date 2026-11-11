#!/usr/bin/env bash
set -euo pipefail

# ── Defaults ───────────────────────────────────────────────────────────────────
DOCKER_USER="aj3x"
IMAGE="${DOCKER_USER}/n8n"

VERSION=""
HASH=""
FORCE=false
VERBOSE=false
STEPS=()

# ── Usage ──────────────────────────────────────────────────────────────────────
usage() {
  cat <<EOF
Usage: $(basename "$0") [STEPS...] [OPTIONS]

Builds and pushes the n8n Docker image to Docker Hub.
If no steps are given, all three run in order: git build push

Steps:
  git     Sync branch and apply local patch
  build   Build and push image as :latest
  push    Tag :latest as versioned and push git tag
  clean   Reset local changes and switch to aj3x branch

Options:
  --version VERSION   Version to build (default: latest npm version)
  --hash HASH         Unique tag suffix (default: random hex)
  --force             Proceed even if the version already exists on Docker Hub
  --verbose           Show commands as they are executed
  --help              Show this message and exit
EOF
}

set_upstream() {
  if ! git remote get-url upstream > /dev/null 2>&1; then
    git remote add upstream https://github.com/n8n-io/n8n.git
  fi
}

# ── Steps ──────────────────────────────────────────────────────────────────────
git_update() {
  set_upstream
  local branch="n8n@${VERSION}"
  git fetch upstream
  git fetch origin
  git checkout "$branch"
  git pull upstream "$branch"
  local base
  base=$(git merge-base aj3x master)
  git diff --binary --full-index "$base" aj3x > patch.diff
  if ! git apply --3way patch.diff; then
    echo "Patch could not be applied cleanly. Resolve the conflicts, then run the remaining steps without rerunning 'git'." >&2
    return 1
  fi
}

build() {
  local builder="n8n-multiarch"
  if ! docker buildx inspect "$builder" > /dev/null 2>&1; then
    docker buildx create --name "$builder" --driver docker-container
  fi
  pnpm i
  node scripts/build-n8n.mjs
  docker buildx build \
    --builder "$builder" \
    --platform linux/amd64,linux/arm64 \
    -f docker/images/n8n/Dockerfile \
    -t "${IMAGE}:latest" \
    --push .
}

push() {
  docker buildx imagetools create -t "${IMAGE}:${VERSION}" "${IMAGE}:latest"
  docker buildx imagetools create -t "${IMAGE}:${VERSION}-${HASH}" "${IMAGE}:latest"

  git add .
  git switch -c "aj3x@${VERSION}"
  git push origin HEAD:"aj3x@${VERSION}"
  git commit -m "aj3x: patch"

  git tag -a "aj3x@${VERSION}" -m "Release $VERSION"
  git push origin "aj3x@${VERSION}"
  
  echo "${IMAGE}:${VERSION}-${HASH}"
}

# ── Argument parsing ───────────────────────────────────────────────────────────
parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --help)           usage; exit 0 ;;
      --version)        VERSION="$2"; shift 2 ;;
      --hash)           HASH="$2"; shift 2 ;;
      --force)          FORCE=true; shift ;;
      --verbose)        VERBOSE=true; shift ;;
      git|build|push|clean)   STEPS+=("$1"); shift ;;
      *)                echo "Unknown argument: $1" >&2; usage; exit 1 ;;
    esac
  done

  # default to all steps if none specified
  if [[ ${#STEPS[@]} -eq 0 ]]; then
    STEPS=(git build push clean)
  fi
}

clean() {
  git reset --hard
  git clean -fd
  git checkout aj3x
}

# ── Main ───────────────────────────────────────────────────────────────────────
main() {
  VERSION="${VERSION:-$(npm view n8n version)}"
  HASH="${HASH:-$(openssl rand -hex 4)}"
  if [[ "$VERBOSE" == true ]]; then
    set -x
  fi

  [[ -z "$VERSION" ]] && { echo "Could not determine n8n version." >&2; exit 1; }
  [[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || { echo "Invalid version: $VERSION" >&2; exit 1; }

  if [[ "$FORCE" == false ]] && docker manifest inspect "${IMAGE}:${VERSION}" > /dev/null 2>&1; then
    echo "Version $VERSION already exists on Docker Hub. Use --force to override." >&2
    exit 1
  fi

  # run in canonical order regardless of how steps were specified
  for step in git build push clean; do
    [[ " ${STEPS[*]} " == *" $step "* ]] || continue
    case "$step" in
      git)   git_update ;;
      build) build ;;
      push)  push ;;
      clean) clean ;;
    esac
  done
}

parse_args "$@"
main
