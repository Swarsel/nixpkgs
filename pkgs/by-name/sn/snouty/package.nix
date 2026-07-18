{
  lib,
  fetchFromGitHub,
  installShellFiles,
  nix-update-script,
  openssl,
  pkg-config,
  podman,
  rustPlatform,
  versionCheckHook,
  writableTmpDirAsHomeHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "snouty";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "antithesishq";
    repo = "snouty";
    tag = "v${finalAttrs.version}";
    hash = "sha256-zO+2UFu/KD2dtE2AkUVv5A1EBFMsSTl8gP18bCxquI8=";
  };

  nativeBuildInputs = [
    installShellFiles
    pkg-config
  ];

  buildInputs = [
    openssl
  ];

  cargoHash = "sha256-fWdzaqyFT2ZFTy5AsejDgEm3E55syLKbYz5DW9Ra2PQ=";
  env.OPENSSL_NO_VENDOR = true;

  nativeCheckInputs = [
    writableTmpDirAsHomeHook
    podman
  ];

  postInstall = ''
    installShellCompletion \
      $releaseDir/build/snouty-*/out/snouty.{bash,fish} \
      --zsh $releaseDir/build/snouty-*/out/_snouty
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  __darwinAllowLocalNetworking = true;
  useNextest = true;
  versionCheckProgramArg = "version";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "CLI for the Antithesis API";
    homepage = "https://github.com/antithesishq/snouty";
    changelog = "https://github.com/antithesishq/snouty/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      carlsverre
      winter
    ];

    mainProgram = "snouty";
  };
})
