class Margrave < Formula
  desc "On-demand skill router: one skill store, ranked search, load on demand"
  homepage "https://github.com/valksor/margrave"
  license "BSD-3-Clause"

  on_macos do
    depends_on arch: :arm64

    on_arm do
      url "https://github.com/valksor/margrave/releases/download/v0.3.2/margrave-v0.3.2-macos-arm64.tar.gz"
      sha256 "c0966edbcb2b89fa32c8fafee598922247e81d43e3723ee0fcc406266cda0228"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/valksor/margrave/releases/download/v0.3.2/margrave-v0.3.2-linux-x64.tar.gz"
      sha256 "9e8b7540a1a79f3683fcd3f50511bd5492690216135abf5890b342df5174b14a"
    end

    on_arm do
      url "https://github.com/valksor/margrave/releases/download/v0.3.2/margrave-v0.3.2-linux-arm64.tar.gz"
      sha256 "90eba3c4b67cf4d1017b6ba84eefb28f19f416d417a75a65a901730947b87c23"
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
