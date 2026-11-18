#!/usr/bin/env bash
# Render Formula/margrave.rb for one margrave release.
# Usage: scripts/render-formula.sh VERSION SHA_MACOS_ARM64 SHA_LINUX_X64 SHA_LINUX_ARM64
set -euo pipefail

usage() {
  echo "usage: ${0##*/} VERSION SHA_MACOS_ARM64 SHA_LINUX_X64 SHA_LINUX_ARM64" >&2
  exit 2
}

[[ $# -eq 4 ]] || usage

version=${1}
sha_macos_arm64=${2}
sha_linux_x64=${3}
sha_linux_arm64=${4}

version_re='^[0-9]+\.[0-9]+\.[0-9]+$'
sha_re='^[0-9a-f]{64}$'

if ! [[ ${version} =~ ${version_re} ]]
then
  echo "${0##*/}: bad VERSION argument: expected MAJOR.MINOR.PATCH" >&2
  exit 1
fi
for pair in "SHA_MACOS_ARM64:${sha_macos_arm64}" "SHA_LINUX_X64:${sha_linux_x64}" "SHA_LINUX_ARM64:${sha_linux_arm64}"
do
  if ! [[ ${pair#*:} =~ ${sha_re} ]]
  then
    echo "${0##*/}: bad ${pair%%:*} argument: expected 64 lowercase hex characters" >&2
    exit 1
  fi
done

root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
out=${root}/Formula/margrave.rb
tmp=$(mktemp "${root}/Formula/.margrave.rb.XXXXXX")
trap 'rm -f "${tmp}"' EXIT

# Quoted delimiter: the shell expands nothing, so Ruby #{...} and the wrapper's
# $-expressions survive. The four validated values replace fixed placeholders.
sed \
  -e "s/@VERSION@/${version}/g" \
  -e "s/@SHA_MACOS_ARM64@/${sha_macos_arm64}/g" \
  -e "s/@SHA_LINUX_X64@/${sha_linux_x64}/g" \
  -e "s/@SHA_LINUX_ARM64@/${sha_linux_arm64}/g" >"${tmp}" <<'TEMPLATE'
class Margrave < Formula
  desc "On-demand skill router: one skill store, ranked search, load on demand"
  homepage "https://github.com/valksor/margrave"
  license "BSD-3-Clause"

  on_macos do
    depends_on arch: :arm64

    on_arm do
      url "https://github.com/valksor/margrave/releases/download/v@VERSION@/margrave-v@VERSION@-macos-arm64.tar.gz"
      sha256 "@SHA_MACOS_ARM64@"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/valksor/margrave/releases/download/v@VERSION@/margrave-v@VERSION@-linux-x64.tar.gz"
      sha256 "@SHA_LINUX_X64@"
    end

    on_arm do
      url "https://github.com/valksor/margrave/releases/download/v@VERSION@/margrave-v@VERSION@-linux-arm64.tar.gz"
      sha256 "@SHA_LINUX_ARM64@"
    end
  end

  def install
    libexec.install Dir["*"]

    (bin/"margrave").write <<~SH
      #!/bin/sh
      install_hint="nvm install --only=alpha 27.0.0-alpha.0.1.0 && nvm use 27.0.0-alpha.0.1.0"
      node_bin=$(command -v node 2>/dev/null) || node_bin=""
      [ -n "$node_bin" ] || {
        echo "margrave: node not found on PATH. margrave needs Node 27 or newer; Homebrew's node is 26. nvm puts node on PATH only in interactive shells. Install: $install_hint" >&2
        exit 1
      }
      node_major=$(node -p 'process.versions.node.split(".")[0]' 2>/dev/null) || node_major=""
      case "$node_major" in
        ""|*[!0-9]*) node_major=0 ;;
      esac
      [ "$node_major" -ge 27 ] || {
        node_version=$(node -p process.version 2>/dev/null) || node_version="unknown version"
        echo "margrave: found Node $node_version at $node_bin; margrave needs Node 27 or newer (Homebrew's node is 26). Install: $install_hint" >&2
        exit 1
      }
      exec node --preserve-symlinks --preserve-symlinks-main "#{opt_libexec}/dist/cli.js" "$@"
    SH
    chmod 0755, bin/"margrave"
  end

  def caveats
    <<~EOS
      margrave needs Node 27 or newer on PATH. This formula does not install Node,
      and Homebrew's node is 26. Install Node 27 with:
        nvm install --only=alpha 27.0.0-alpha.0.1.0 && nvm use 27.0.0-alpha.0.1.0
    EOS
  end

  test do
    system libexec/"vendor/ripwire/ripwire", "--version"
  end
end
TEMPLATE

mv "${tmp}" "${out}"
chmod 0644 "${out}"
trap - EXIT
