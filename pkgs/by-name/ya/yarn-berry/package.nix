{
  lib,
  stdenv,
  fetchFromGitHub,
  callPackage,
  nodejs,
  pkgs,
  testers,
  yarn,
  berryVersion ? 4,
}:

let
  version_4 = "4.14.1";
  version_3 = "3.8.7";
  hash_4 = "sha256-0UnU5jRSUFMw+WowvXqYqaaN1ZbZAdLLJ6LPyuK6iCc=";
  hash_3 = "sha256-vRrk+Fs/7dZha3h7yI5NpMfd1xezesnigpFgTRCACZo=";
in

stdenv.mkDerivation (finalAttrs: {
  pname = "yarn-berry";
  version = if berryVersion == 4 then version_4 else version_3;

  src = fetchFromGitHub {
    owner = "yarnpkg";
    repo = "berry";
    tag = "@yarnpkg/cli/${finalAttrs.version}";
    hash = if berryVersion == 4 then hash_4 else hash_3;
  };

  strictDeps = true;

  nativeBuildInputs = [
    nodejs
    yarn
  ];

  buildInputs = [
    nodejs
  ];

  buildPhase = ''
    runHook preBuild
    yarn workspace @yarnpkg/cli build:cli
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -Dm 755 ./packages/yarnpkg-cli/bundles/yarn.js "$out/bin/yarn"
    runHook postInstall
  '';

  dontConfigure = true;

  passthru = {
    tests =
      let
        packageTests =
          if berryVersion == 4 then
            {
              inherit (pkgs)
                prettier
                corepack
                katex
                ;
            }
          else
            {
              inherit (pkgs)
                svgo
                yarn-lock-converter
                ;
            };
      in
      packageTests
      // {
        version = testers.testVersion {
          package = finalAttrs.finalPackage;
        };
      };

    updateScript = ./update.sh;
  }
  // (callPackage ./fetcher { yarn-berry = finalAttrs; });

  meta = {
    description = "Fast, reliable, and secure dependency management";
    homepage = "https://yarnpkg.com/";
    changelog = "https://github.com/yarnpkg/berry/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.bsd2;

    maintainers = with lib.maintainers; [
      ryota-ka
      pyrox0
      DimitarNestorov
    ];

    platforms = lib.platforms.unix;
    mainProgram = "yarn";
  };
})
