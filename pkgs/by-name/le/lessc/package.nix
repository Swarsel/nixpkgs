{
  lib,
  stdenv,
  fetchFromGitHub,
  callPackage,
  fetchPnpmDeps,
  lessc,
  nix-update-script,
  nodejs,
  pnpmConfigHook,
  pnpm_11,
  runCommand,
  testers,
  writeText,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "lessc";
  version = "4.6.7";

  src = fetchFromGitHub {
    owner = "less";
    repo = "less.js";
    tag = "v${finalAttrs.version}";
    hash = "sha256-D/gPyPoxHeLjF7EU40Jw2Mb4ZRrnaLq8XnL+kL2yhic=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    pnpmConfigHook
    pnpm_11
    nodejs
  ];

  buildInputs = [ nodejs ];

  buildPhase = ''
    runHook preBuild

    pnpm --filter "less" run build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,lib/lessc}
    cp -r {packages,node_modules} $out/lib/lessc
    chmod +x $out/lib/lessc/packages/less/bin/lessc
    ln -s $out/lib/lessc/packages/less/bin/lessc $out/bin/lessc

    runHook postInstall
  '';

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs)
      pname
      version
      src
      pnpmWorkspaces
      ;

    fetcherVersion = 4;
    hash = "sha256-tlms2b0aodWkI+btdmCnwSDgsURekaBdiI8IZ/iMVnI=";
    pnpm = pnpm_11;
  };

  pnpmWorkspaces = [ "less..." ];

  passthru = {
    plugins = callPackage ./plugins { };

    tests = {
      version = testers.testVersion { package = lessc; };

      simple = testers.testEqualContents {
        actual =
          runCommand "actual"
            {
              nativeBuildInputs = [ lessc ];

              base = writeText "base" ''
                @color: red;
                body {
                  h1 {
                    color: @color;
                  }
                }
              '';
            }
            ''
              lessc $base > $out
            '';

        assertion = "lessc compiles a basic less file";

        expected = writeText "expected" ''
          body h1 {
            color: red;
          }
        '';
      };
    };

    updateScript = nix-update-script { };
    withPlugins = fn: lessc.wrapper.override { plugins = fn lessc.plugins; };
    wrapper = callPackage ./wrapper { };
  };

  meta = {
    description = "Dynamic stylesheet language";
    homepage = "https://github.com/less/less.js";
    changelog = "https://github.com/less/less.js/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ lelgenio ];
    mainProgram = "lessc";
  };
})
