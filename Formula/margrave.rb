class Margrave < Formula
  desc "On-demand skill router: one skill store, ranked search, load on demand"
  homepage "https://github.com/valksor/margrave"
  license "BSD-3-Clause"

  on_macos do
    depends_on arch: :arm64

    on_arm do
      url "https://github.com/valksor/margrave/releases/download/v0.1.2/margrave-v0.1.2-macos-arm64.tar.gz"
      sha256 "062dd0a96697a15f801d9189ab851ad10afdd15a0363153a51e7f118bdc9739a"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/valksor/margrave/releases/download/v0.1.2/margrave-v0.1.2-linux-x64.tar.gz"
      sha256 "7870b8c42377bd3b384bced328a4895c6ea91f6bee879259a84f387a5dbb41da"
    end

    on_arm do
      url "https://github.com/valksor/margrave/releases/download/v0.1.2/margrave-v0.1.2-linux-arm64.tar.gz"
      sha256 "17bbfa668e6e0d941f3616a8b8b7e9c3add8c127fbf700dce7d6b68d0bfb8bc6"
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
