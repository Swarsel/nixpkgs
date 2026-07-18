{
  lib,
  fetchFromGitHub,
  blade-formatter,
  fetchYarnDeps,
  nix-update-script,
  nodejs,
  runCommand,
  stdenvNoCC,
  testers,
  writeText,
  yarnBuildHook,
  yarnConfigHook,
  yarnInstallHook,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "blade-formatter";
  version = "1.44.4";

  src = fetchFromGitHub {
    owner = "shufo";
    repo = "blade-formatter";
    rev = "v${finalAttrs.version}";
    hash = "sha256-/HuYfAf0JwDzWKpc6ymsfl6NjfwnnzduVX/LGwuE1uo=";
  };

  nativeBuildInputs = [
    yarnConfigHook
    yarnBuildHook
    yarnInstallHook
    nodejs
  ];

  yarnOfflineCache = fetchYarnDeps {
    hash = "sha256-gVAJO74lSwBaWS19/GeAPWUfRJIjeMA6Gqzk46VA8hU=";
    yarnLock = finalAttrs.src + "/yarn.lock";
  };

  passthru = {
    tests = {
      version = testers.testVersion {
        command = "blade-formatter --version";
        package = blade-formatter;
      };

      simple = testers.testEqualContents {
        actual =
          runCommand "actual"
            {
              nativeBuildInputs = [ blade-formatter ];

              base = writeText "base" ''
                @if(   true )  Hello world!   @endif
              '';
            }
            ''
              blade-formatter $base > $out
            '';

        assertion = "blade-formatter formats a basic blade file";

        expected = writeText "expected" ''
          @if (true)
              Hello world!
          @endif
        '';
      };
    };

    updateScript = nix-update-script { };
  };

  meta = {
    inherit (nodejs.meta) platforms;
    description = "Laravel Blade template formatter";
    homepage = "https://github.com/shufo/blade-formatter";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ lelgenio ];
    mainProgram = "blade-formatter";
  };
})
