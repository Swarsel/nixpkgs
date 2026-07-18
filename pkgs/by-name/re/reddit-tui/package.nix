{
  lib,
  fetchFromGitHub,
  buildGoModule,
  callPackage,
  nix-update-script,
}:
buildGoModule (finalAttrs: {
  pname = "reddit-tui";
  version = "0.3.9";

  src = fetchFromGitHub {
    owner = "tonymajestro";
    repo = "reddit-tui";
    tag = "v${finalAttrs.version}";
    hash = "sha256-dqmxY3AkJ03/zbn+6irh43luUrGaVQ/5lGzl5jeUNDE=";
  };

  vendorHash = "sha256-Yqo80adzA9gtSD3qzM+fObzRt3WbcMATQef0g7/z2Dw=";
  doCheck = false;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Terminal UI for reddit";

    longDescription = ''
      Due to suspected throttling by reddit, it might be necessary to use a [redlib backend](https://github.com/redlib-org/redlib) to enable this package to work.
      See [the Docs](https://github.com/tonymajestro/reddit-tui#configuration-files) on how to do that.
    '';

    homepage = "https://github.com/tonymajestro/reddit-tui";
    changelog = "https://github.com/tonymajestro/reddit-tui/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.LazilyStableProton ];
    mainProgram = "reddittui";
  };
})
