class Margrave < Formula
  desc "On-demand skill router: one skill store, ranked search, load on demand"
  homepage "https://github.com/valksor/margrave"
  license "BSD-3-Clause"

  on_macos do
    depends_on arch: :arm64

    on_arm do
      url "https://github.com/valksor/margrave/releases/download/v0.4.1/margrave-v0.4.1-macos-arm64.tar.gz"
      sha256 "4771f5fcc66783307bc39e3390fdf7db982a3e090527e49ace66047e8ef24339"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/valksor/margrave/releases/download/v0.4.1/margrave-v0.4.1-linux-x64.tar.gz"
      sha256 "6123ca36743c3f6b384236cbaff17a6a1c7d2d6c38e4a8bfc120755d53ab147c"
    end

    on_arm do
      url "https://github.com/valksor/margrave/releases/download/v0.4.1/margrave-v0.4.1-linux-arm64.tar.gz"
      sha256 "fe299f5319fbca04d4e65653df3481a9f5e1e5af44fcb50da56fe661e7df0eff"
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
