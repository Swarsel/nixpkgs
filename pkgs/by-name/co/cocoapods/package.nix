{
  lib,
  bundlerApp,
  ruby,
  beta ? false,
}:

bundlerApp {
  inherit ruby;
  pname = "cocoapods";
  exes = [ "pod" ];
  gemfile = if beta then ./Gemfile-beta else ./Gemfile;
  gemset = if beta then ./gemset-beta.nix else ./gemset.nix;
  lockfile = if beta then ./Gemfile-beta.lock else ./Gemfile.lock;
  # toString prevents the update script from being copied into the nix store
  passthru.updateScript = toString ./update;

  meta = {
    description = "Manages dependencies for your Xcode projects";
    homepage = "https://github.com/CocoaPods/CocoaPods";
    license = lib.licenses.mit;
    platforms = lib.platforms.darwin;
    mainProgram = "pod";
  };
}
