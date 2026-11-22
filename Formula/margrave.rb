class Margrave < Formula
  desc "On-demand skill router: one skill store, ranked search, load on demand"
  homepage "https://github.com/valksor/margrave"
  license "BSD-3-Clause"

  on_macos do
    depends_on arch: :arm64

    on_arm do
      url "https://github.com/valksor/margrave/releases/download/v0.3.5/margrave-v0.3.5-macos-arm64.tar.gz"
      sha256 "0ca7b7632e86c6e6bb07b467f1c3c165f83f3a360be837d91657ecfb5098ae77"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/valksor/margrave/releases/download/v0.3.5/margrave-v0.3.5-linux-x64.tar.gz"
      sha256 "ce881070562f350393396380f8451042e5ef2bbd297e2a2f2f91f562561bf02d"
    end

    on_arm do
      url "https://github.com/valksor/margrave/releases/download/v0.3.5/margrave-v0.3.5-linux-arm64.tar.gz"
      sha256 "c9cccf0f2dc180507b3e2779d18f1e687ec8561c75076e20ffbba50f35877e98"
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
