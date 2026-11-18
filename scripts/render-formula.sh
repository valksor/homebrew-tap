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

    # A wrapper, not a symlink: the binary sees the stable opt path as the path
    # it was started from, so `margrave wrap` output survives `brew upgrade`.
    (bin/"margrave").write <<~SH
      #!/bin/sh
      exec "#{opt_libexec}/bin/margrave" "$@"
    SH
    chmod 0755, bin/"margrave"
  end

  test do
    system bin/"margrave", "--help"
    system libexec/"vendor/ripwire/ripwire", "--version"
    assert_path_exists libexec/"licenses/node/LICENSE"
  end
end
TEMPLATE

mv "${tmp}" "${out}"
chmod 0644 "${out}"
trap - EXIT
