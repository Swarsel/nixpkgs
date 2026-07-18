{
  lib,
  stdenv,
  fetchPnpmDeps,
  nodejs,
  pnpmConfigHook,
  pnpm_11,
  wox,
}:
stdenv.mkDerivation (finalAttrs: {
  inherit (wox)
    version
    src
    ;

  pname = "wox-plugin-host-nodejs";

  nativeBuildInputs = [
    nodejs
    pnpmConfigHook
    pnpm_11
  ];

  buildPhase = ''
    runHook preBuild

    pnpm run build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm644 dist/index.js $out/node-host.js

    runHook postInstall
  '';

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs)
      pname
      version
      src
      sourceRoot
      ;

    fetcherVersion = 4;
    hash = "sha256-6zQDbNUxysqwrRaEMp8Sb5Vcf2HdkkdrdCpJwG8pHSs=";
    pnpm = pnpm_11;
  };

  sourceRoot = "${finalAttrs.src.name}/wox.plugin.host.nodejs";

  meta = {
    inherit (wox.meta)
      description
      homepage
      license
      maintainers
      ;
  };
})
