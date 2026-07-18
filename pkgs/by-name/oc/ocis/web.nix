{
  lib,
  fetchFromGitHub,
  fetchPnpmDeps,
  nodejs,
  pnpmBuildHook,
  pnpmConfigHook,
  pnpm_9,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation rec {
  pname = "ocis-web";
  version = "8.0.5";

  src = fetchFromGitHub {
    owner = "owncloud";
    repo = "web";
    tag = "v${version}";
    hash = "sha256-hupdtK/V74+X7/eXoDmUjFvSKuhnoOtNQz7o6TLJXG4=";
  };

  nativeBuildInputs = [
    nodejs
    pnpmConfigHook
    pnpmBuildHook
    pnpm_9
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share
    cp -r dist/* $out/share/
    runHook postInstall
  '';

  pnpmDeps = fetchPnpmDeps {
    inherit
      pname
      version
      src
      ;

    fetcherVersion = 3;
    hash = "sha256-EsoGio2D8HZmbe+uuzsOhhwaLMSbJcfV4iUJUaqtA0M=";
    pnpm = pnpm_9;
  };

  meta = {
    description = "ownCloud Infinite Scale Stack";
    homepage = "https://github.com/owncloud/ocis";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ xinyangli ];
  };
}
