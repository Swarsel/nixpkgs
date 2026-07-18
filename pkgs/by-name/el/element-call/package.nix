{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchPnpmDeps,
  nodejs,
  pnpmConfigHook,
  pnpm_10,
  runCommand,
}:

let
  pnpm = pnpm_10;

  # Separately build matrix-js-sdk, as upstream expects to 'pnpm i && pnpm build' in the dependency's directory
  # Keep this in sync with upstream locked version (likely a stable release, but not always latest)
  matrix-js-sdk = stdenv.mkDerivation (finalAttrs: {
    pname = "matrix-js-sdk";
    version = "41.8.0";

    src = fetchFromGitHub {
      owner = "matrix-org";
      repo = "matrix-js-sdk";
      tag = "v${finalAttrs.version}";
      hash = "sha256-9OWB3Hz8EoDIu27jvA6Am4l1dH53IZGE9TStB2Viw6E=";
    };

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

      mkdir $out
      cp -r src $out/
      cp -r lib $out/
      cp package.json $out/

      runHook postInstall
    '';

    pnpmDeps = fetchPnpmDeps {
      inherit (finalAttrs) pname version src;
      inherit pnpm;
      fetcherVersion = 4;
      hash = "sha256-Me76t/wl4HtmbQ+FzUNLEpOM6aYbzTl68tuDSEh+Hq4=";
    };
  });
in
stdenv.mkDerivation (finalAttrs: {
  inherit matrix-js-sdk;
  pname = "element-call";
  version = "0.20.3";

  src = fetchFromGitHub {
    owner = "element-hq";
    repo = "element-call";
    tag = "v${finalAttrs.version}";
    hash = "sha256-H+In5fsX82eMDGk5kaS5ulqU1U5S67auEPc24rtCkuA=";
  };

  nativeBuildInputs = [
    nodejs
    pnpmConfigHook
    pnpm
  ];

  buildPhase = ''
    runHook preBuild
    # Instead of making an override, invalidating the pnpm lock, just add the built files in lib right before invoking pnpm build
    cp -r ${finalAttrs.matrix-js-sdk}/* node_modules/matrix-js-sdk/
    pnpm build
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir $out
    cp -r dist/* $out

    runHook postInstall
  '';

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    inherit pnpm;
    fetcherVersion = 4;
    hash = "sha256-JOpKxtElmNKepx3W+1LIolcrYrevsCEq7+Aoh0kwZEw=";
  };

  passthru = {
    inherit (finalAttrs) matrix-js-sdk;

    tests.build = runCommand "${finalAttrs.pname}-test" { } ''
      test -f ${finalAttrs.finalPackage}/index.html
      test -d ${finalAttrs.finalPackage}/assets
      touch $out
    '';
  };

  meta = {
    description = "Group calls powered by Matrix";
    homepage = "https://github.com/element-hq/element-call";
    changelog = "https://github.com/element-hq/element-call/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.agpl3Only;

    maintainers = with lib.maintainers; [
      bartoostveen
      kilimnik
    ];
  };
})
