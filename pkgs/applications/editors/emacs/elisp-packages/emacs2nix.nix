let
  pkgs = import ../../../../.. { };

  src = pkgs.fetchFromGitHub {
    owner = "nix-community";
    repo = "emacs2nix";
    rev = "9458961fc433a6c4cd91e7763f0aa1ef15f7b4aa";
    hash = "sha256-NJVKrYSF/22hrUJNJ3/znbcfHi/FtTePQ8Xzfp2eKAk=";
    fetchSubmodules = true;
  };
in
pkgs.mkShell {

  EMACS2NIX = src;

  packages = [
    pkgs.bash
    pkgs.nixfmt
  ];

  shellHook = ''
    export PATH=$PATH:${src}
  '';

}
