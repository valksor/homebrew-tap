class Margrave < Formula
  desc "On-demand skill router: one skill store, ranked search, load on demand"
  homepage "https://github.com/valksor/margrave"
  license "BSD-3-Clause"

  on_macos do
    depends_on arch: :arm64

    on_arm do
      url "https://github.com/valksor/margrave/releases/download/v0.2.1/margrave-v0.2.1-macos-arm64.tar.gz"
      sha256 "a28b26290a24a6995c96ab1191f70f594dba0704ea6f609ce51c5376e371f033"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/valksor/margrave/releases/download/v0.2.1/margrave-v0.2.1-linux-x64.tar.gz"
      sha256 "b9b9460ff338df2ce74408d9958a6bd0647878ca4b4b643160a7f4686f359463"
    end

    on_arm do
      url "https://github.com/valksor/margrave/releases/download/v0.2.1/margrave-v0.2.1-linux-arm64.tar.gz"
      sha256 "cae3c78c7f1763801db847e3de658edaccc3cdd3a020868d90ec0547c10b4cdc"
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
