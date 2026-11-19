# valksor/tap

Homebrew tap for [margrave](https://github.com/valksor/margrave), an on-demand skill router: one skill store, ranked search, load on demand.

## Install

```sh
brew install valksor/tap/margrave
```

Platforms: macOS arm64, Linux x64, Linux arm64.

margrave is a single binary with its own runtime, so Node is not needed. The Linux binaries need glibc.

If you ran `margrave wrap` with a formula older than the binary release, run it again and re-apply its output: the old agent configs start `node .../dist/cli.js`, which no longer exists.

## How the formula stays current

The formula follows margrave releases. The "Update margrave formula" workflow is scheduled to run every 10 minutes. It reads the latest release of `valksor/margrave`, verifies each of the three release assets with `gh attestation verify`, and only then updates `Formula/margrave.rb` and pushes. GitHub can delay or skip scheduled runs, so a new release can take longer than 10 minutes to reach the tap.

GitHub disables scheduled workflows in a public repository after 60 days without repository activity. To re-enable the schedule, open Actions, select "Update margrave formula", and click "Enable workflow".

## Render the formula by hand

```sh
scripts/render-formula.sh VERSION SHA_MACOS_ARM64 SHA_LINUX_X64 SHA_LINUX_ARM64
```

`VERSION` is `MAJOR.MINOR.PATCH` without the `v`. Each SHA is the lowercase 64-character SHA-256 of the matching release asset. The script refuses any other input and writes `Formula/margrave.rb`.

## License

BSD 3-Clause. See `LICENSE`.
