{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchYarnDeps,
  nix-update-script,
  nodejs,
  yarnBuildHook,
  yarnConfigHook,
  yarnInstallHook,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "sql-formatter";
  version = "15.7.4";

  src = fetchFromGitHub {
    owner = "sql-formatter-org";
    repo = "sql-formatter";
    rev = "v${finalAttrs.version}";
    hash = "sha256-cUTijVuBerUlK8xDbq1u6f0P6aSgXjcDaTf/F9jMBAA=";
  };

  nativeBuildInputs = [
    yarnBuildHook
    yarnConfigHook
    yarnInstallHook
    nodejs
  ];

  yarnOfflineCache = fetchYarnDeps {
    hash = "sha256-zcCYGTuaPkizZHc4K6RAPWwMnP5LtnyaLbF9xcPpNBs=";
    yarnLock = "${finalAttrs.src}/yarn.lock";
  };

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Whitespace formatter for different query languages";
    homepage = "https://sql-formatter-org.github.io/sql-formatter";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "sql-formatter";
  };
})
