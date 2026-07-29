#!/bin/sh
pnpm i
pnpm build

VERSION=$(npm view n8n version)

# regex version number
if [[ ! $VERSION =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Invalid version number: $VERSION"
  exit 1
fi

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

echo "aj3x/n8n:$VERSION-$HASH"