class Margrave < Formula
  desc "On-demand skill router: one skill store, ranked search, load on demand"
  homepage "https://github.com/valksor/margrave"
  license "BSD-3-Clause"

  on_macos do
    depends_on arch: :arm64

    on_arm do
      url "https://github.com/valksor/margrave/releases/download/v0.3.3/margrave-v0.3.3-macos-arm64.tar.gz"
      sha256 "41d3515e8e11ccdd9b8d5716d357bc1b23b1279a52b8bd0c7f5d7a8dab6da08b"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/valksor/margrave/releases/download/v0.3.3/margrave-v0.3.3-linux-x64.tar.gz"
      sha256 "53dbeac1ecdc4b34948c378a00c96fdd8a4fe8a6badd9b6c39de85875d2773b2"
    end

    on_arm do
      url "https://github.com/valksor/margrave/releases/download/v0.3.3/margrave-v0.3.3-linux-arm64.tar.gz"
      sha256 "3558f82cb00c8bced89434d2bd77c981b8a65a508750ac7fea8f2e0b664c60ce"
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
