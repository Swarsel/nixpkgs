{
  lib,
  fetchFromGitLab,
  nixosTests,
  php,
  writeScript,
}:

php.buildComposerProject2 (finalAttrs: {
  pname = "drupal";
  version = "11.4.2";

  src = fetchFromGitLab {
    owner = "project";
    repo = "drupal";
    tag = finalAttrs.version;
    hash = "sha256-GHhavn9H1x7xo72r9KSOSkrOzW4jEBAe033m2ATeh2E=";
    domain = "git.drupalcode.org";
  };

  vendorHash = "sha256-1Qns0npuzdVONtkDk3tXlGib9VCnbM6zVOVIsMRfZks=";
  composerNoPlugins = false;

  passthru = {
    tests = {
      inherit (nixosTests) drupal;
    };

    updateScript = writeScript "update.sh" ''
      #!/usr/bin/env nix-shell
      #!nix-shell -i bash -p nix-update xmlstarlet

      set -eu -o pipefail

      version=$(curl -k --silent --globoff "https://updates.drupal.org/release-history/drupal/current" | xmlstarlet sel -t -v "/project/releases/release/tag[not(contains(., 'alpha'))][not(contains(., 'beta'))][not(contains(., '-rc'))]" | grep -m 1 '.')

      nix-update drupal --version $version
    '';
  };

  meta = {
    description = "Drupal CMS";
    homepage = "https://drupal.org/";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      OulipianSummer
    ];

    platforms = php.meta.platforms;
  };
})
