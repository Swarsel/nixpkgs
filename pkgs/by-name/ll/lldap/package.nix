{
  lib,
  fetchFromGitHub,
  binaryen,
  cacert,
  curl,
  makeWrapper,
  nixosTests,
  runCommand,
  rustPlatform,
  rustc,
  wasm-bindgen-cli_0_2_120,
  wasm-pack,
  which,
  staticAssetsHash ? "sha256-xVbHD9s3ofbtHCDvjYwmsWXDEJ9z9vRxQDRR6pW6rt8=",
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "lldap";
  version = "0.6.3";

  src = fetchFromGitHub {
    owner = "lldap";
    repo = "lldap";
    rev = "v${finalAttrs.version}";
    hash = "sha256-EafYBCorK5t8ZLoXTjqLg+Q6GDRZjalpRqSoVySdpOk=";
  };

  nativeBuildInputs = [ makeWrapper ];
  cargoHash = "sha256-GhSoPDMsWRuW6SYS/QTPgsA7fBFup5C5+DBqnlFqwlQ=";

  postInstall = ''
    wrapProgram $out/bin/lldap \
      --set LLDAP_ASSETS_PATH ${finalAttrs.finalPackage.frontend}
  '';

  cargoBuildFlags = [
    "-p"
    "lldap"
    "-p"
    "lldap_migration_tool"
    "-p"
    "lldap_set_password"
  ];

  ## workaround for overrideAttrs on buildRustPackage
  ## see https://discourse.nixos.org/t/is-it-possible-to-override-cargosha256-in-buildrustpackage/4393/3
  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) src patches;
    hash = finalAttrs.cargoHash;
    name = "${finalAttrs.pname}-cargo-deps";
  };

  passthru = {

    frontend = rustPlatform.buildRustPackage {
      inherit (finalAttrs)
        version
        src
        cargoDeps
        patches
        ;

      pname = finalAttrs.pname + "-frontend";

      nativeBuildInputs = [
        wasm-pack
        wasm-bindgen-cli_0_2_120
        binaryen
        which
        rustc
        rustc.llvmPackages.lld
      ];

      buildPhase = ''
        runHook preBuild
        HOME=`pwd` ./app/build.sh
        runHook postBuild
      '';

      doCheck = false;

      installPhase = ''
        runHook preInstall
        mkdir -p $out
        cp -R app/{pkg,static} $out/
        cp app/index_local.html $out/index.html
        cp -R ${finalAttrs.finalPackage.staticAssets}/* $out/static
        rm $out/static/libraries.txt $out/static/fonts/fonts.txt
        runHook postInstall
      '';
    };

    staticAssets =
      runCommand "${finalAttrs.pname}-static-assets"
        {
          inherit (finalAttrs) src;

          nativeBuildInputs = [
            curl
          ];

          env.SSL_CERT_FILE = "${cacert}/etc/ssl/certs/ca-bundle.crt";
          outputHash = staticAssetsHash;
          outputHashAlgo = "sha256";
          outputHashMode = "recursive";
        }
        ''
          mkdir $out
          mkdir $out/fonts
          for file in $(cat $src/app/static/libraries.txt); do
            curl $file --location --remote-name --output-dir $out
          done
          for file in $(cat $src/app/static/fonts/fonts.txt); do
            curl $file --location --remote-name --output-dir $out/fonts
          done
        '';

    tests = {
      inherit (nixosTests) lldap;
    };

  };

  meta = {
    description = "Lightweight authentication server that provides an opinionated, simplified LDAP interface for authentication";
    homepage = "https://github.com/lldap/lldap";
    changelog = "https://github.com/lldap/lldap/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.gpl3Only;

    maintainers = with lib.maintainers; [
      bendlas
      ibizaman
    ];

    platforms = lib.platforms.linux;
    mainProgram = "lldap";
  };
})
