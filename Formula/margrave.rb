class Margrave < Formula
  desc "On-demand skill router: one skill store, ranked search, load on demand"
  homepage "https://github.com/valksor/margrave"
  license "BSD-3-Clause"

  on_macos do
    depends_on arch: :arm64

    on_arm do
      url "https://github.com/valksor/margrave/releases/download/v0.1.5/margrave-v0.1.5-macos-arm64.tar.gz"
      sha256 "37527568caee3829cc41ceaceebb0acf194b4ea01a1809639a376773cef92fe7"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/valksor/margrave/releases/download/v0.1.5/margrave-v0.1.5-linux-x64.tar.gz"
      sha256 "876fb3585cedd904ad28075fe8ec58c8b2897424e0c6bbe5a4ac8ec0b0cd5266"
    end

    on_arm do
      url "https://github.com/valksor/margrave/releases/download/v0.1.5/margrave-v0.1.5-linux-arm64.tar.gz"
      sha256 "82f64f70b558649fa427fd90fd2c698f4ae50a8f0ec88f9cd3043720f440a962"
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
