{
  lib,
  fetchFromGitHub,
  makeBinaryWrapper,
  nix-update-script,
  rustPlatform,
  versionCheckHook,
  wofi,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "wofi-power-menu";
  version = "0.3.4";

  src = fetchFromGitHub {
    owner = "szaffarano";
    repo = "wofi-power-menu";
    tag = "v${finalAttrs.version}";
    hash = "sha256-5dhwDfWL0pP28rgbS5eoOARrXDZVTF6EDNimcfcjH3Y=";
  };

  nativeBuildInputs = [ makeBinaryWrapper ];
  cargoHash = "sha256-Avful4JlhYrdHpzWfseCmmx5jxuOJxEA2Yl6dfkJpXs=";

  postInstall = ''
    wrapProgram $out/bin/wofi-power-menu \
      --prefix PATH : ${lib.makeBinPath [ wofi ]}
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Highly configurable power menu using the wofi launcher power-menu";
    homepage = "https://github.com/szaffarano/wofi-power-menu";
    changelog = "https://github.com/szaffarano/wofi-power-menu/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ defelo ];
    mainProgram = "wofi-power-menu";
  };
})
