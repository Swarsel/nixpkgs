{
  lib,
  fetchFromGitHub,
  buildGoModule,
  callPackage,
  nixosTests,
  stdenvNoCC,
  withLocales ? true,
}:

let
  version = "2024.9.2";
  src = fetchFromGitHub {
    owner = "cortezaproject";
    repo = "corteza";
    tag = version;
    hash = "sha256-1mekSiRfFSNa/6MSzwRrI3rb9GHABkn3i1b6tX+73fI=";
  };
  meta = {
    description = "Low-code platform";

    longDescription = ''
      The Corteza low-code platform lets you build and iterate CRM, business
      process and other structured data apps fast, create intelligent business
      process workflows and connect with almost any data source.
    '';

    homepage = "https://cortezaproject.org/";
    changelog = "https://docs.cortezaproject.org/corteza-docs/${lib.versions.majorMinor version}/changelog/index.html";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ prince213 ];
    downloadPage = "https://github.com/cortezaproject/corteza/releases";
    teams = with lib.teams; [ ngi ];
  };

  mkWebApp =
    name: hash:
    callPackage ./buildYarnDistOnly.nix {
      inherit
        version
        src
        hash
        meta
        ;

      pname = "corteza-webapp-${name}";
      extraFiles = "../../../{README.md,LICENSE,CONTRIBUTING.md,DCO}";
      sourceDir = "client/web/${name}";
    };

  webApps = lib.mapAttrs mkWebApp {
    admin = "sha256-34lfnK2mecvu1Lgg9IM61+fbnqRgZC/Agi7iyugn0fM=";
    compose = "sha256-1/Fyl6Z27TtZzNBeerKYNs4VhLWEW3wJyr0SCapzc9E=";
    discovery = "sha256-mL+ibAgVFCRV5AvN0VZc4LCCY8hyaIC8gOlgEdXayuU=";
    one = "sha256-SuGf72y4PXatZJQgbW5X4mPjtJmQlpwbjfFYCEZElBU=";
    privacy = "sha256-yHi6pq0OKCh+2reygNL7TvwULCHwxeD8BXVVMjlnpLc=";
    reporter = "sha256-AWKSzULOTdUZ5wdlTo8dJwVGc7RlYbimR4YF4ZAN1pQ=";
    workflow = "sha256-cxD2mG4uuO8KT1r2Y4opPlY84Hvqu7cbWh2BSo8CcEc=";
  };

  server-webconsole = callPackage ./buildYarnDistOnly.nix {
    inherit version src meta;
    pname = "corteza-server-webconsole";
    hash = "sha256-GMXrQtplreg/3bWfRwQQwDNiHQNl6YHF5nhmFNCYsiM=";
    sourceDir = "server/webconsole";
    yarnLock = ./server-webconsole-yarn.lock;
  };

  corteza-locale = fetchFromGitHub {
    owner = "cortezaproject";
    repo = "corteza-locale";
    rev = "64b6d5d562dce642652db55949231abf8b9af4ef";
    sha256 = "sha256-OKr/M91sEDlTwYBiDXwWkShlfazJBm21G0uU429fjW0=";
  };

  corteza-webapp = stdenvNoCC.mkDerivation (finalAttrs: {
    inherit version meta;
    pname = "corteza-webapp";

    buildPhase = ''
      runHook preBuild

      cp --no-preserve=mode -r ${webApps.one.name} dist
      ${lib.concatStringsSep "\n" (
        lib.attrValues (
          lib.mapAttrs (name: src: ''
            cp -r ${src.name} dist/${name}
          '') (lib.removeAttrs webApps [ "one" ])
        )
      )}

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out
      cp -r dist/* $out

      runHook postInstall
    '';

    sourceRoot = ".";
    srcs = lib.attrValues webApps;
  });

  corteza-server = buildGoModule (finalAttrs: {
    inherit version src;
    pname = "corteza-server";
    # already vendored
    vendorHash = null;

    preBuild = ''
      cp -r ../locale/en pkg/locale/src/
      cp -r ${server-webconsole}/* webconsole/dist/
    ''
    + lib.optionalString withLocales ''
      cp -r ${corteza-locale}/src/* pkg/locale/src/
    '';

    postInstall = ''
      mv $out/bin/corteza{,-server}
      cp -r provision .env.example ../{README.md,LICENSE,CONTRIBUTING.md,DCO} $out
      rm -f $out/provision/README.adoc $out/provision/update.sh
    '';

    sourceRoot = "${finalAttrs.src.name}/server";
    subPackages = [ "cmd/corteza" ];

    meta = meta // {
      platforms = lib.platforms.unix;
      mainProgram = "corteza-server";
    };
  });
in
stdenvNoCC.mkDerivation (finalAttrs: {
  inherit version;
  inherit (corteza-server) meta;
  pname = "corteza";

  buildPhase = ''
    runHook preBuild

    cp --no-preserve=mode -r ${finalAttrs.passthru.srcs.corteza-server.name} dist
    chmod a+x dist/bin/corteza-server
    mkdir dist/webapp
    cp -r ${finalAttrs.passthru.srcs.corteza-webapp.name}/* dist/webapp

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    cp -r dist $out

    runHook postInstall
  '';

  sourceRoot = ".";
  srcs = lib.attrValues finalAttrs.passthru.srcs;

  passthru = {
    srcs = { inherit corteza-server corteza-webapp; };
    tests = { inherit (nixosTests) corteza; };
  };
})
