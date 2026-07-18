{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,
  versionCheckHook,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "gavin-bc";
  version = "7.1.0";

  src = fetchFromGitHub {
    owner = "gavinhoward";
    repo = "bc";
    rev = finalAttrs.version;
    hash = "sha256-bIQk0HzUzL1Ju4+iDpFj1n+GKCj9a3AUAbYA3yX5TNg=";
  };

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgram = "${placeholder "out"}/bin/bc";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Gavin Howard's BC calculator implementation";
    homepage = "https://github.com/gavinhoward/bc";
    changelog = "https://github.com/gavinhoward/bc/blob/${finalAttrs.version}/NEWS.md";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ delafthi ];
    platforms = lib.platforms.unix;
  };
})
