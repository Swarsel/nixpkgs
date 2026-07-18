{
  lib,
  fetchFromGitHub,
  fetchYarnDeps,
  nix-update-script,
  nodejs,
  stdenvNoCC,
  yarnConfigHook,
  yarnInstallHook,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "gramma";
  version = "1.6.0";

  src = fetchFromGitHub {
    owner = "caderek";
    repo = "gramma";
    tag = "v${finalAttrs.version}";
    hash = "sha256-gfBwKpsttdhjD/Opn8251qskURpwLX2S5NSbpwP3hFg=";
  };

  postPatch = ''
    # Set a script name to avoid yargs using cli.js as $0
    substituteInPlace src/cli.js \
      --replace-fail '.demandCommand()' '.demandCommand().scriptName("gramma")'
  '';

  nativeBuildInputs = [
    yarnConfigHook
    yarnInstallHook
    nodejs
  ];

  offlineCache = fetchYarnDeps {
    hash = "sha256-FuR6wUhAaej/vMgjAlICMEj1pPf+7PFrdu2lTFshIkg=";
    yarnLock = "${finalAttrs.src}/yarn.lock";
  };

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Command-line grammar checker";
    homepage = "https://caderek.github.io/gramma/";
    changelog = "https://github.com/caderek/gramma/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.isc;
    maintainers = [ ];
    mainProgram = "gramma";
  };
})
