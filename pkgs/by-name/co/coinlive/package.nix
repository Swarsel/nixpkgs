{
  lib,
  fetchFromGitHub,
  openssl,
  pkg-config,
  rustPlatform,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "coinlive";
  version = "0.2.5";

  src = fetchFromGitHub {
    owner = "mayeranalytics";
    repo = "coinlive";
    tag = "v${finalAttrs.version}";
    hash = "sha256-FQAxY0ZiC8bkp1s2CIpQeC6ZBNKm5/qmaebPuDcHtd4=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    openssl
  ];

  cargoHash = "sha256-1mzfuH5988PDKBsbKl0R1v/3/3Hk3LJtklqMA83tEOY=";

  checkFlags = [
    # Test requires network access
    "--skip=utils::test_get_infos"
  ];

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  meta = {
    description = "Live cryptocurrency prices CLI";
    homepage = "https://github.com/mayeranalytics/coinlive";
    changelog = "https://github.com/mayeranalytics/coinlive/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "coinlive";
  };
})
