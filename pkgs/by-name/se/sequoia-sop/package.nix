{
  lib,
  fetchFromGitLab,
  installShellFiles,
  nettle,
  nix-update-script,
  pkg-config,
  rustPlatform,
  sqlite,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "sequoia-sop";
  version = "0.38.0";

  src = fetchFromGitLab {
    owner = "sequoia-pgp";
    repo = "sequoia-sop";
    tag = "v${finalAttrs.version}";
    hash = "sha256-3PxUXMLRBqw9GO0+wRiwI7P6/RH9vuAkSN4OnSxV0SQ=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    pkg-config
    rustPlatform.bindgenHook
    installShellFiles
  ];

  buildInputs = [
    nettle
    sqlite
  ];

  cargoHash = "sha256-iKC6vIT8fVFv/Yx3YJUSCHyTOZ7X860Ak0l/+7lrU9Y=";
  env.ASSET_OUT_DIR = "target";
  doCheck = true;

  # Install manual pages
  postInstall = ''
    installManPage ${finalAttrs.env.ASSET_OUT_DIR}/man-pages/*.*
    installShellCompletion --cmd sqop \
      --bash ${finalAttrs.env.ASSET_OUT_DIR}/shell-completions/sqop.bash \
      --fish ${finalAttrs.env.ASSET_OUT_DIR}/shell-completions/sqop.fish \
      --zsh ${finalAttrs.env.ASSET_OUT_DIR}/shell-completions/_sqop
    # Also elv and powershell are generated there
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  __structuredAttrs = true;
  buildFeatures = [ "cli" ];
  versionCheckProgramArg = "version";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Implementation of the Stateless OpenPGP Command Line Interface using Sequoia";
    homepage = "https://gitlab.com/sequoia-pgp/sequoia-sop";
    changelog = "https://gitlab.com/sequoia-pgp/sequoia-sop/-/blob/${finalAttrs.src.tag}/NEWS";
    license = lib.licenses.gpl2Plus;

    maintainers = with lib.maintainers; [
      doronbehar
      anish
    ];

    mainProgram = "sqop";
  };
})
