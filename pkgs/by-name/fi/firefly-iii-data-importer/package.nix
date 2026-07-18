{
  lib,
  fetchFromGitHub,
  buildPackages,
  fetchNpmDeps,
  nix-update-script,
  nixosTests,
  nodejs-slim,
  php85,
  stdenvNoCC,
  dataDir ? "/var/lib/firefly-iii-data-importer",
}:

let
  php = php85;
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "firefly-iii-data-importer";
  version = "2.3.4";

  src = fetchFromGitHub {
    owner = "firefly-iii";
    repo = "data-importer";
    tag = "v${finalAttrs.version}";
    hash = "sha256-869oPalwVdc7Ge8zcG6OniTZ6zhLOknlvFQkEHzLg0M=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    nodejs-slim
    nodejs-slim.npm
    nodejs-slim.python
    buildPackages.npmHooks.npmConfigHook
    php.composerHooks.composerInstallHook
    php.packages.composer-local-repo-plugin
  ];

  buildInputs = [ php ];
  vendorHash = "sha256-GEioAwqo9BHzoP4/uetqiQgv+O9Qzqyo/AcW9VP23n0=";

  preInstall = ''
    npm run build --workspace=v2
  '';

  postInstall = ''
    rm -R $out/share/php/firefly-iii-data-importer/{storage,bootstrap/cache,node_modules}
    mv $out/share/php/firefly-iii-data-importer/* $out/
    rm -R $out/share
    ln -s ${dataDir}/storage $out/storage
    ln -s ${dataDir}/cache $out/bootstrap/cache
  '';

  composerNoDev = true;
  composerNoPlugins = true;
  composerNoScripts = true;

  composerRepository = php.mkComposerRepository {
    inherit (finalAttrs)
      pname
      src
      vendorHash
      version
      ;

    composerNoDev = true;
    composerNoPlugins = true;
    composerNoScripts = true;
    composerStrictValidation = true;
  };

  composerStrictValidation = true;

  npmDeps = fetchNpmDeps {
    inherit (finalAttrs) src;
    hash = "sha256-FEEC89/7cEuKU4mY27Pm5nr5EkOoL7BWZRAOpCZK61I=";
    name = "${finalAttrs.pname}-npm-deps";
  };

  passthru = {
    phpPackage = php;
    tests = nixosTests.firefly-iii-data-importer;

    updateScript = nix-update-script {
      extraArgs = [
        "--version-regex"
        "v(\\d+\\.\\d+\\.\\d+)"
      ];
    };
  };

  meta = {
    description = "Firefly III Data Importer can import data into Firefly III";
    homepage = "https://github.com/firefly-iii/data-importer";
    changelog = "https://github.com/firefly-iii/data-importer/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.agpl3Only;
    maintainers = [ lib.maintainers.savyajha ];
  };
})
