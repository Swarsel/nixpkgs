{
  lib,
  fetchPnpmDeps,
  nodejs,
  opencloud,
  pnpmBuildHook,
  pnpmConfigHook,
  pnpm_11,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  inherit (opencloud) src version;
  pname = "opencloud-idp-web";

  nativeBuildInputs = [
    nodejs
    pnpmConfigHook
    pnpmBuildHook
    pnpm_11
  ];

  postBuild = ''
    mkdir -p services/idp/assets/identifier/static
    cp -v services/idp/src/images/favicon.svg services/idp/assets/identifier/static/favicon.svg
    cp -v services/idp/src/images/icon-lilac.svg services/idp/assets/identifier/static/icon-lilac.svg
  '';

  installPhase = ''
    runHook preInstall

    mkdir $out
    cp -r services/idp/assets $out

    runHook postInstall
  '';

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    fetcherVersion = 4;
    hash = "sha256-buDYvRw4NTLxFSdDRZHiuXMVe9fJbe2iu5hr+zh6KLs=";
    pnpm = pnpm_11;
    sourceRoot = "${finalAttrs.src.name}/${finalAttrs.pnpmRoot}";
  };

  pnpmRoot = "services/idp";

  meta = {
    description = "OpenCloud - IDP Web UI";
    homepage = "https://github.com/opencloud-eu/opencloud";
    changelog = "https://github.com/opencloud-eu/opencloud/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      christoph-heiss
      k900
    ];

    platforms = lib.platforms.all;
  };
})
