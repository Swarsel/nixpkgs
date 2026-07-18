{
  lib,
  fetchFromGitHub,
  php,
}:

let
  version = "5.2.0";
in
php.buildComposerWithPlugin {
  inherit version;
  pname = "cyclonedx/cyclonedx-php-composer";

  src = fetchFromGitHub {
    owner = "CycloneDX";
    repo = "cyclonedx-php-composer";
    rev = "v${version}";
    hash = "sha256-0fb1QiuVJqcB7CAEyB0y60/O9iiibT06mccZYe52dFQ=";
  };

  vendorHash = "sha256-QPlHWXXksetNSsv3olmCtPA/VsFVPV09rYQEsPezZoE=";
  composerLock = ./composer.lock;

  meta = {
    description = "Composer plugin that facilitates the creation of a CycloneDX Software Bill of Materials (SBOM) from PHP Composer projects";
    homepage = "https://github.com/CycloneDX/cyclonedx-php-composer";
    changelog = "https://github.com/CycloneDX/cyclonedx-php-composer/releases/tag/v${version}";
    license = lib.licenses.asl20;
    maintainers = [ ];
    platforms = lib.platforms.all;
    mainProgram = "composer";
  };
}
