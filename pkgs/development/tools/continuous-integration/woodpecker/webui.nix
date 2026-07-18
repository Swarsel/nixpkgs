{
  lib,
  stdenv,
  callPackage,
  fetchPnpmDeps,
  nodejs,
  pnpmConfigHook,
  pnpm_11,
}:
let
  common = callPackage ./common.nix { };

  pnpm = pnpm_11;
in
stdenv.mkDerivation (finalAttrs: {
  inherit (common) version src;
  pname = "woodpecker-webui";

  nativeBuildInputs = [
    nodejs
    pnpmConfigHook
    pnpm
  ];

  buildPhase = ''
    runHook preBuild

    pnpm build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    cp -r dist $out

    runHook postInstall
  '';

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    inherit pnpm;
    fetcherVersion = 4;
    hash = common.nodeModulesHash;
    sourceRoot = "${common.src.name}/web";
  };

  sourceRoot = "${common.src.name}/web";

  meta = common.meta // {
    description = "Woodpecker Continuous Integration server webui";
  };
})
