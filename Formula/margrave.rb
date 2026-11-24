class Margrave < Formula
  desc "On-demand skill router: one skill store, ranked search, load on demand"
  homepage "https://github.com/valksor/margrave"
  license "BSD-3-Clause"

  on_macos do
    depends_on arch: :arm64

    on_arm do
      url "https://github.com/valksor/margrave/releases/download/v0.4.0/margrave-v0.4.0-macos-arm64.tar.gz"
      sha256 "359545501e2da42c80177abcc2a554f76137521cc6e5959d88169a6f4f957bc1"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/valksor/margrave/releases/download/v0.4.0/margrave-v0.4.0-linux-x64.tar.gz"
      sha256 "f0a34f579b827fc4f41016ee292ce3859fe45b75a490f74688b9208860725052"
    end

    on_arm do
      url "https://github.com/valksor/margrave/releases/download/v0.4.0/margrave-v0.4.0-linux-arm64.tar.gz"
      sha256 "750b11a34cc3c5883b4cd7ef391cd7d83984cfe235a81271f4df18047fb2ebec"
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
