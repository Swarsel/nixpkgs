{
  fetchFromGitHub,
  crystal,
  mkTmuxPlugin,
  replaceVars,
}:
let
  fingers = crystal.buildCrystalPackage rec {
    pname = "fingers";
    version = "2.7.1";

    src = fetchFromGitHub {
      owner = "Morantron";
      repo = "tmux-fingers";
      rev = "${version}";
      sha256 = "sha256-4aA60127Pv1jk7jzEhlU3NmPDmUbp9nE/8yYKkcMUb4=";
    };

    # TODO: Needs starting a TMUX session to run tests
    # Unhandled exception: Missing ENV key: "TMUX" (KeyError)
    doCheck = false;

    postInstall = ''
      shopt -s dotglob extglob
      rm -rv !("tmux-fingers.tmux"|"bin")
      shopt -u dotglob extglob
    '';

    doInstallCheck = false;
    crystalBinaries.tmux-fingers.src = "src/fingers.cr";
    format = "shards";
    shardsFile = ./shards.nix;

    meta = {
      homepage = "https://github.com/Morantron/tmux-fingers";
    };
  };
in
mkTmuxPlugin {
  inherit (fingers) version src meta;

  patches = [
    (replaceVars ./fix.patch {
      tmuxFingersDir = "${fingers}/bin";
    })
  ];

  pluginName = fingers.src.repo;
  rtpFilePath = "tmux-fingers.tmux";
}
