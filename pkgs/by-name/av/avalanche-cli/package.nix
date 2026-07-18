{
  lib,
  stdenv,
  fetchFromGitHub,
  blst,
  buildGoModule,
  buildPackages,
  installShellFiles,
  libusb1,
  makeWrapper,
  nix-update-script,
  versionCheckHook,
  writableTmpDirAsHomeHook,
}:
buildGoModule (finalAttrs: {
  pname = "avalanche-cli";
  version = "1.9.6";

  src = fetchFromGitHub {
    owner = "ava-labs";
    repo = "avalanche-cli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-bAZJRFlry7vYTTf95kTOJwcjYelN40n264oeykx7nxc=";
  };

  patches = [ ./skip_min_version_check.patch ];

  nativeBuildInputs = [
    installShellFiles
    makeWrapper
    writableTmpDirAsHomeHook
  ];

  buildInputs = [
    blst
    libusb1
  ];

  vendorHash = "sha256-0+YwlCHjiU46y333RSuaha4pLKFTYlj+M9+TFAALamY=";

  env = {
    # Fix error: 'Caught SIGILL in blst_cgo_init'
    # https://github.com/bnb-chain/bsc/issues/1521
    CGO_CFLAGS = "-O -D__BLST_PORTABLE__";
    CGO_CFLAGS_ALLOW = "-O -D__BLST_PORTABLE__";
  };

  doCheck = false;

  postInstall =
    let
      exe =
        if stdenv.buildPlatform.canExecute stdenv.hostPlatform then
          "$out/bin/avalanche"
        else
          lib.getExe buildPackages.avalanche-cli;
    in
    ''
      mv $out/bin/avalanche-cli $out/bin/avalanche
      wrapProgram $out/bin/avalanche --add-flags "--skip-update-check"

      mkdir $HOME/.avalanche-cli
      echo "{ }" > $HOME/.avalanche-cli/config.json

      installShellCompletion --cmd avalanche \
        --bash <(${exe} completion bash) \
        --fish <(${exe} completion fish) \
        --zsh <(${exe} completion zsh)
    '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  ldflags = [
    "-s"
    "-X=github.com/ava-labs/avalanche-cli/cmd.Version=${finalAttrs.version}"
  ];

  proxyVendor = true;
  versionCheckProgram = "${placeholder "out"}/bin/avalanche";

  meta = {
    description = "Command line tool that gives developers access to everything Avalanche";
    homepage = "https://github.com/ava-labs/avalanche-cli";
    changelog = "https://github.com/ava-labs/avalanche-cli/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.unfreeRedistributable;
    maintainers = with lib.maintainers; [ iamanaws ];
    mainProgram = "avalanche";
  };
})
