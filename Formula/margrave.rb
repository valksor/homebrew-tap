class Margrave < Formula
  desc "On-demand skill router: one skill store, ranked search, load on demand"
  homepage "https://github.com/valksor/margrave"
  license "BSD-3-Clause"

  on_macos do
    depends_on arch: :arm64

    on_arm do
      url "https://github.com/valksor/margrave/releases/download/v0.1.3/margrave-v0.1.3-macos-arm64.tar.gz"
      sha256 "b67c539d9430a71562658ed734d04748cd2dc94b8aa3e16facb573c6de202d44"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/valksor/margrave/releases/download/v0.1.3/margrave-v0.1.3-linux-x64.tar.gz"
      sha256 "452af65d245575a3a2d54b8a876902c64102c36af51d5dec9009a4470a318c44"
    end

    on_arm do
      url "https://github.com/valksor/margrave/releases/download/v0.1.3/margrave-v0.1.3-linux-arm64.tar.gz"
      sha256 "b8a882698540acdf84e75d1f559af8ccbe536f52ef47085db70c431905bb378d"
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
