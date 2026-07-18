{
  lib,
  fetchFromGitHub,
  buildPackages,
  fetchNpmDeps,
  fetchzip,
  nix-update-script,
  nixosTests,
  nodejs-slim,
  php85,
  stdenvNoCC,
  dataDir ? "/var/lib/firefly-iii",
}:
let
  php = php85;
  version = "6.6.3";

  # Release tarball contains translations downloaded from crowdin
  releaseTarball = fetchzip {
    hash = "sha256-vPuLCjU8MzV5odoDl9QQXj4kKnT6QBSAPwvekMxJtEM=";
    stripRoot = false;
    url = "https://github.com/firefly-iii/firefly-iii/releases/download/v${version}/FireflyIII-v${version}.tar.gz";
  };
in
stdenvNoCC.mkDerivation (finalAttrs: {
  inherit version;
  pname = "firefly-iii";

  src = fetchFromGitHub {
    owner = "firefly-iii";
    repo = "firefly-iii";
    tag = "v${finalAttrs.version}";
    hash = "sha256-MPBWurmtaIaKHRLf4TPCdgTVWRZ0JdZ0Ix2N7d80s8c=";
  };

  nativeBuildInputs = [
    nodejs-slim
    nodejs-slim.npm
    nodejs-slim.python
    buildPackages.npmHooks.npmConfigHook
    php.packages.composer
    php.composerHooks2.composerInstallHook
  ];

  buildInputs = [ php ];

  preInstall = ''
    npm run prod --workspace=v1
    npm run build --workspace=v2
  '';

  postInstall = ''
    chmod -R u+w $out/share
    mv $out/share/php/firefly-iii/* $out/

    # Copy language files from release tarball (contains all translations)
    cp -r ${finalAttrs.passthru.releaseTarball}/resources/lang/* $out/resources/lang/

    rm -R $out/share $out/storage $out/bootstrap/cache $out/node_modules
    ln -s ${dataDir}/storage $out/storage
    ln -s ${dataDir}/cache $out/bootstrap/cache
  '';

  composerVendor = php.mkComposerVendor {
    inherit (finalAttrs) pname src version;
    strictDeps = true;
    vendorHash = "sha256-qjMDZbPpyTkKxvZhgNERe2ZuRFj7LmRW7XZoeezizbk=";
    composerStrictValidation = true;
  };

  npmDeps = fetchNpmDeps {
    inherit (finalAttrs) src;
    hash = "sha256-QlLFhrD94mpfoe9mmCVmem9E4oPsLAGMMf+MbI/5Vx0=";
    name = "${finalAttrs.pname}-npm-deps";
  };

  passthru = {
    inherit releaseTarball;
    phpPackage = php;
    tests = nixosTests.firefly-iii;

    updateScript = nix-update-script {
      extraArgs = [
        "--version-regex"
        "v(\\d+\\.\\d+\\.\\d+)"
      ];
    };
  };

  meta = {
    description = "Firefly III: a personal finances manager";
    homepage = "https://github.com/firefly-iii/firefly-iii";
    changelog = "https://github.com/firefly-iii/firefly-iii/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.agpl3Only;

    maintainers = [
      lib.maintainers.savyajha
      lib.maintainers.patrickdag
    ];

    hydraPlatforms = lib.platforms.linux; # build hangs on both Darwin platforms, needs investigation
  };
})
