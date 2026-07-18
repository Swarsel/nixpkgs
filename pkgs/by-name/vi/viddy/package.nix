{
  lib,
  fetchFromGitHub,
  rustPlatform,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "viddy";
  version = "1.3.1";

  src = fetchFromGitHub {
    owner = "sachaos";
    repo = "viddy";
    tag = "v${finalAttrs.version}";
    hash = "sha256-RyPG8OAg3i9N2Fq5Hij48wMvfQuTNmJFpatvB3HbXKg=";
  };

  cargoHash = "sha256-P+TtxV2kuHeBHr8GQeJ0VWPkjimfcAtBUFt0z79ML6A=";

  env = {
    VERGEN_BUILD_DATE = "2026-06-14"; # managed via the update script
    VERGEN_GIT_DESCRIBE = "Nixpkgs";
  };

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  __structuredAttrs = true;

  preInstallCheck = ''
    export VIDDY_DATA="$PWD";
  '';

  versionCheckKeepEnvironment = [ "VIDDY_DATA" ];
  versionCheckProgramArg = "-V";
  passthru.updateScript = ./update.sh;

  meta = {
    description = "Modern `watch` command";
    homepage = "https://github.com/sachaos/viddy";
    changelog = "https://github.com/sachaos/viddy/releases/tag/${finalAttrs.src.rev}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      j-hui
      phanirithvij
    ];

    mainProgram = "viddy";
  };
})
