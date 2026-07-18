{
  lib,
  fetchFromGitHub,
  php,
}:

let
  version = "1.1.0";
in
php.buildComposerWithPlugin {
  inherit version;
  pname = "nix-community/composer-local-repo-plugin";

  src = fetchFromGitHub {
    owner = "nix-community";
    repo = "composer-local-repo-plugin";
    rev = version;
    hash = "sha256-edbn07r/Uc1g0qOuVBZBs6N1bMN5kIfA1b4FCufdw5M=";
  };

  vendorHash = "sha256-cup8maS9NkhdqTHoKJaH7r7AJQdkflWTvM6uIuxMPX0=";
  composerLock = ./composer.lock;

  meta = {
    description = "Composer plugin that facilitates the creation of a local composer type repository";
    homepage = "https://github.com/nix-community/composer-local-repo-plugin";
    changelog = "https://github.com/nix-community/composer-local-repo-plugin/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.all;
    mainProgram = "composer";
  };
}
