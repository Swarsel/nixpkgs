{
  stdenv,
  fetchYarnDeps,
  lauti,
  nodejs,
  src,
  version,
  yarnBuildHook,
  yarnConfigHook,
}:

stdenv.mkDerivation (finalAttrs: {
  inherit version src;
  pname = "lauti";

  nativeBuildInputs = [
    yarnConfigHook
    yarnBuildHook
    # Needed for executing package.json scripts
    nodejs
  ];

  preBuild = ''
    cd backstage
  '';

  installPhase = ''
    runHook preInstall

    yarn --offline --production install

    mkdir -p "$out"
    cp -r . $out/

    runHook postInstall
  '';

  offlineCache = fetchYarnDeps {
    hash = "sha256-RKalgQ6dXNOxMeC6pSKe9Lo0KXN0gfeX0I/pkcv2FXs=";
    yarnLock = "${finalAttrs.src}/yarn.lock";
  };

  meta = {
    inherit (lauti.meta)
      homepage
      description
      license
      maintainers
      ;
  };
})
