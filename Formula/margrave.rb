class Margrave < Formula
  desc "On-demand skill router: one skill store, ranked search, load on demand"
  homepage "https://github.com/valksor/margrave"
  license "BSD-3-Clause"

  on_macos do
    depends_on arch: :arm64

    on_arm do
      url "https://github.com/valksor/margrave/releases/download/v0.1.4/margrave-v0.1.4-macos-arm64.tar.gz"
      sha256 "cc1b4a8b33f6276802ecc834b1d44591f1068be0d437187a97da1e9e0f510bf8"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/valksor/margrave/releases/download/v0.1.4/margrave-v0.1.4-linux-x64.tar.gz"
      sha256 "5770cb7004fc6364b52e56f8ea1a20caba3004b48c04028c2f2f90df375e9cbc"
    end

    on_arm do
      url "https://github.com/valksor/margrave/releases/download/v0.1.4/margrave-v0.1.4-linux-arm64.tar.gz"
      sha256 "01b0b8b02f6b2051d9f42cda920e8bb9b202d29960eb53d79e9adfde2144674b"
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
