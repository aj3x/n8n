#!/bin/sh
set -euo pipefail




function usage() {
  echo "Usage: $0 [build <version>] [--help]"
  echo "Builds the n8n docker image and pushes it to Docker Hub."
  echo ""
  echo "Options:"
  echo "  --help    Show this help message and exit."
  echo "  --version VERSION    Specify the version to build and push. If not specified, the latest version will be used."
  echo "  --h, --hash HASH    Specify a hash to use as a unique identifier for the subagent. If not specified, a random hash will be generated."
  echo "  --only-build    Only build the docker image, do not push it to Docker Hub."
  echo "  --only-push    Only push the docker image to Docker Hub, do not build it."
  echo "  --no-git-update    Do not update the git repository before building the docker image."
}

function main() {
  if [ "$#" -gt 0 ]; then
    case "$1" in
      --help)
        usage
        exit 0
        ;;
      
      *)
        echo "Unknown option: $1"
        usage
        exit 1
        ;;
    esac
  fi

  git_update

  build_and_push
}

BASE_BRANCH="master"
VERSION=$(npm view n8n version)

BASE_BRANCH="n8n@$VERSION"

# regex version number
if [[ ! $VERSION =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Invalid version number: $VERSION"
  exit 1
fi

main "$@"

function git_update() {
  git fetch upstream
  git fetch origin
  git checkout "$BASE_BRANCH"
  git pull upstream "$BASE_BRANCH"
  git push
  git checkout aj3x
  git rebase origin/"$BASE_BRANCH"
  git push --force-with-lease
}


function build_and_push() {
  node scripts/build-n8n.mjs

  # create a random hash string to use as a unique identifier for the subagent
  HASH=$(openssl rand -hex 4)

  docker buildx build \
    --platform linux/amd64,linux/arm64 \
    -f docker/images/n8n/Dockerfile \
    -t aj3x/n8n:latest \
    --push .

  docker buildx imagetools create -t aj3x/n8n:$VERSION aj3x/n8n:latest
  docker buildx imagetools create -t aj3x/n8n:$VERSION-$HASH aj3x/n8n:latest

  git tag -a $VERSION -m "Release $VERSION"
  git push origin $VERSION

  echo "aj3x/n8n:$VERSION-$HASH"
}