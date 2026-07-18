{
  lib,
  fetchFromGitHub,
  rustPlatform,
  testers,
  weggli,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "weggli";
  version = "0.2.4";

  src = fetchFromGitHub {
    owner = "weggli-rs";
    repo = "weggli";
    rev = "v${finalAttrs.version}";
    hash = "sha256-6XSedsTUjcZzFXaNitsXlUBpxC6TYVMCB+AfH3x7c5E=";
  };

  cargoHash = "sha256-vJd+4cZuDSGThnkUULhwEUFbHlkiIGyxT+1fWRUsIJk=";

  passthru.tests.version = testers.testVersion {
    version = "weggli ${finalAttrs.version}";
    command = "weggli -V";
    package = weggli;
  };

  meta = {
    description = "Fast and robust semantic search tool for C and C++ codebases";
    homepage = "https://github.com/weggli-rs/weggli";
    changelog = "https://github.com/weggli-rs/weggli/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      arturcygan
      mfrw
    ];

    mainProgram = "weggli";
  };
})
