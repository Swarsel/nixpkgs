{
  lib,
  fetchFromGitHub,
  applyPatches,
  buildGoModule,
  callPackage,
  fetchPnpmDeps,
  gnumake,
  nodejs,
  ocis,
  pnpmConfigHook,
  pnpm_9,
  stdenvNoCC,
}:
let
  idp-assets = stdenvNoCC.mkDerivation {
    pname = "idp-assets";
    version = "0-unstable-2020-10-14";

    src = fetchFromGitHub {
      owner = "owncloud";
      repo = "assets";
      rev = "e8b6aeadbcee1865b9df682e9bd78083842d2b5c";
      hash = "sha256-PzGff2Zx8xmvPYQa4lS4yz2h+y/lerKvUZkYI7XvAUw=";
    };

    installPhase = ''
      mkdir -p $out/share
      cp logo.svg favicon.ico $out/share/
    '';

    dontBuild = true;
    dontConfigure = true;
    dontFixup = true;
  };
in
buildGoModule rec {
  pname = "ocis";
  version = "5.0.9";

  src = applyPatches {
    patches = [
      # Remove the kpop dependency, whose upstream tarball
      # (https://download.kopano.io/community/kapp:/kpop-2.2.0.tgz) is no longer
      # available. Adapted from the upstream fix in v8.0.1
      # (https://github.com/owncloud/ocis/pull/12043).
      ./remove-kpop.patch
    ];

    src = fetchFromGitHub {
      owner = "owncloud";
      repo = "ocis";
      tag = "v${version}";
      hash = "sha256-TsMrQx+P1F2t66e0tGG0VvRi4W7+pCpDHd0aNsacOsI=";
    };
  };

  nativeBuildInputs = [
    gnumake
    nodejs
    pnpmConfigHook
    pnpm_9
  ];

  vendorHash = null;

  buildPhase = ''
    runHook preBuild
    cp -r ${ocis.web}/share/* services/web/assets/
    pnpm -C services/idp build

    mkdir -p services/idp/assets/identifier/static
    cp -r ${idp-assets}/share/* services/idp/assets/identifier/static/

    make -C ocis VERSION=${version} DATE=${version} build
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin/
    cp ocis/bin/ocis $out/bin/
    runHook postInstall
  '';

  pnpmDeps = fetchPnpmDeps {
    inherit
      pname
      version
      src
      ;

    fetcherVersion = 3;
    hash = "sha256-5iRnRxFJAWePyx83464guOqBqmao2pybaC4sFVPCOqk=";
    pnpm = pnpm_9;
    sourceRoot = "${src.name}/services/idp";
  };

  pnpmRoot = "services/idp";

  passthru = {
    updateScript = ./update.sh;
    web = callPackage ./web.nix { };
  };

  meta = {
    description = "Next generation frontend for ownCloud Infinite Scale";
    homepage = "https://github.com/owncloud/web";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ xinyangli ];
    mainProgram = "ocis";
  };
}
