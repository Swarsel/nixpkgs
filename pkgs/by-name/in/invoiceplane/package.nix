{
  lib,
  fetchFromGitHub,
  fetchYarnDeps,
  fetchzip,
  grunt-cli,
  nixosTests,
  php,
  yarnBuildHook,
  yarnConfigHook,
  yarnInstallHook,
}:
let
  version = "1.7.1";
  # Fetch release tarball which contains language files
  # https://github.com/InvoicePlane/InvoicePlane/issues/1170
  languages = fetchzip {
    hash = "sha256-DpQazuLOJnNGrrQo7l6uQReoKZEd5es2DT0a50NuQB0=";
    url = "https://github.com/InvoicePlane/InvoicePlane/releases/download/v${version}/v${version}.zip";
  };
in
php.buildComposerProject2 (finalAttrs: {
  inherit version;
  pname = "invoiceplane";

  src = fetchFromGitHub {
    owner = "InvoicePlane";
    repo = "InvoicePlane";
    tag = "v${version}";
    hash = "sha256-Nci5GaCMYIjewq0W5emE6TDgc6JPz4bVVF3okNtHUag=";
  };

  nativeBuildInputs = [
    yarnConfigHook
    yarnBuildHook
    yarnInstallHook
    # Needed for executing package.json scripts
    grunt-cli
  ];

  vendorHash = "sha256-adKvKWo55SSbEKpgMJzR9vJQA8DnNXOTfSzp7t8s2Nk=";

  postBuild = ''
    grunt build
  '';

  # Cleanup and language files
  postInstall = ''
    chmod -R u+w $out/share
    mv $out/share/php/invoiceplane/* $out/
    cp -r ${languages}/application/language $out/application/
    rm -r $out/{composer.json,composer.lock,CONTRIBUTING.md,docker-compose.yml,Gruntfile.js,package.json,node_modules,yarn.lock,share}
  '';

  # Composer.lock validation currently fails for unknown reason
  composerStrictValidation = true;

  offlineCache = fetchYarnDeps {
    inherit (finalAttrs) src patches;
    hash = "sha256-rJlOYMnzFKui+caIFD4d82Q/RcDYnadeJ1G56fcNNQY=";
  };

  passthru.tests = {
    inherit (nixosTests) invoiceplane;
  };

  meta = {
    description = "Self-hosted open source application for managing your invoices, clients and payments";
    homepage = "https://www.invoiceplane.com";
    changelog = "https://github.com/InvoicePlane/InvoicePlane/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ onny ];
    platforms = lib.platforms.all;
  };
})
