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
  pname = "countryfetch";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "nik-rev";
    repo = "countryfetch";
    tag = "v${finalAttrs.version}";
    hash = "sha256-povKd1Y/2Mi+6yJd9+RsJ4F19/wvXvBOK2Jgbs4UnP0=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ];
  cargoHash = "sha256-0ZBhRheJGapPqVieXbIpoboVV4RLXan042u5SSgrYQk=";

  env = {
    OPENSSL_NO_VENDOR = true;
  };

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  cargoBuildFlags = [ "--package=countryfetch" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Command-line tool similar to Neofetch for obtaining information about your country";
    homepage = "https://github.com/nik-rev/countryfetch";
    changelog = "https://github.com/nik-rev/countryfetch/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ defelo ];
    mainProgram = "countryfetch";
  };
})
