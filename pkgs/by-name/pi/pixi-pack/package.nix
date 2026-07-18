{
  lib,
  fetchFromGitHub,
  nix-update-script,
  openssl,
  pkg-config,
  rustPlatform,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "pixi-pack";
  version = "0.7.10";

  src = fetchFromGitHub {
    owner = "Quantco";
    repo = "pixi-pack";
    tag = "v${finalAttrs.version}";
    hash = "sha256-5PU+ro+uE1iiBkgQocMYlHZmiS8+bScP1rF3VVXpn/c=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ];
  cargoHash = "sha256-9Of4qnt+MFrW42daZiLdHrbH5Z7tYpcN6Sg95FUlcQc=";
  # Needed to get openssl-sys to use pkgconfig.
  env.OPENSSL_NO_VENDOR = 1;
  # Tests require downloading artifacts from conda.
  doCheck = false;
  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Pack and unpack conda environments created with pixi";
    homepage = "https://github.com/Quantco/pixi-pack";
    changelog = "https://github.com/Quantco/pixi-pack/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.bsd3;

    maintainers = with lib.maintainers; [
      xiaoxiangmoe
    ];

    mainProgram = "pixi-pack";
  };
})
