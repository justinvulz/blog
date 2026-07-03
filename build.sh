#!/usr/bin/env bash
# Build script for Cloudflare Workers Builds (Ubuntu 24.04, x86_64).
# Downloads the Tola release binary, then builds the static site into ./public.
# Cloudflare then runs the deploy command (`npx wrangler deploy`) using wrangler.jsonc.
set -euo pipefail

TOLA_VERSION="${TOLA_VERSION:-v0.7.1}" # override via a build variable in the CF dashboard

echo "Installing Tola ${TOLA_VERSION}..."
curl -sSfL "https://github.com/tola-rs/tola-ssg/releases/download/${TOLA_VERSION}/tola-x86_64-linux-static.tar.gz" | tar xz

echo "Building site..."
./tola build

echo "Build complete -> ./public"
