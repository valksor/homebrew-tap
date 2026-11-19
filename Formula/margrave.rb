class Margrave < Formula
  desc "On-demand skill router: one skill store, ranked search, load on demand"
  homepage "https://github.com/valksor/margrave"
  license "BSD-3-Clause"

  on_macos do
    depends_on arch: :arm64

    on_arm do
      url "https://github.com/valksor/margrave/releases/download/v0.2.0/margrave-v0.2.0-macos-arm64.tar.gz"
      sha256 "20a87b7c98c3d59f3ad4f0046de486ad2e0751fd05918ad052923200b2b532ec"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/valksor/margrave/releases/download/v0.2.0/margrave-v0.2.0-linux-x64.tar.gz"
      sha256 "46201457ecd7e048fe7db2805e8724e31d79516db9e74e387d3a9b9c28fc2a6f"
    end

    on_arm do
      url "https://github.com/valksor/margrave/releases/download/v0.2.0/margrave-v0.2.0-linux-arm64.tar.gz"
      sha256 "1d68126717ade789ac38c7460c14e915f9f9d866192e820989968ccb4672e46f"
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
