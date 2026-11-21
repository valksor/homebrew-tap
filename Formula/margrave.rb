class Margrave < Formula
  desc "On-demand skill router: one skill store, ranked search, load on demand"
  homepage "https://github.com/valksor/margrave"
  license "BSD-3-Clause"

  on_macos do
    depends_on arch: :arm64

    on_arm do
      url "https://github.com/valksor/margrave/releases/download/v0.3.0/margrave-v0.3.0-macos-arm64.tar.gz"
      sha256 "9b8ba7eb2f3f9a064a541974e4e0eb6384514f36b2805c0066e47a729c9d6936"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/valksor/margrave/releases/download/v0.3.0/margrave-v0.3.0-linux-x64.tar.gz"
      sha256 "50cd4c6c582b287366b8bf92df0c209c6647e714bf80a0f6353c469f8e8bf69e"
    end

    on_arm do
      url "https://github.com/valksor/margrave/releases/download/v0.3.0/margrave-v0.3.0-linux-arm64.tar.gz"
      sha256 "783576b33ab05c550e6899c28b3ce269b3a0b5c478244a40a877ac9da62c2505"
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
