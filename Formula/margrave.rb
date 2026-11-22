class Margrave < Formula
  desc "On-demand skill router: one skill store, ranked search, load on demand"
  homepage "https://github.com/valksor/margrave"
  license "BSD-3-Clause"

  on_macos do
    depends_on arch: :arm64

    on_arm do
      url "https://github.com/valksor/margrave/releases/download/v0.3.4/margrave-v0.3.4-macos-arm64.tar.gz"
      sha256 "a1b8eba6b56ae9e941bb3e4e47341e17c809e864660b5a7177f3ebca5d2e628c"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/valksor/margrave/releases/download/v0.3.4/margrave-v0.3.4-linux-x64.tar.gz"
      sha256 "fec15acab858951353c728b3c822221017b2bc9a3cf2f596c6ca79c3322acb89"
    end

    on_arm do
      url "https://github.com/valksor/margrave/releases/download/v0.3.4/margrave-v0.3.4-linux-arm64.tar.gz"
      sha256 "01c22fc77af3d4896a3bac5fc6ea462c24adecf595da77abeb45ebee1a35fe62"
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
