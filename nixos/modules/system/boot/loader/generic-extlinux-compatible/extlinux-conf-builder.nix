{ lib, pkgs }:

pkgs.replaceVarsWith {
  isExecutable = true;

  replacements = {
    inherit (pkgs) bash;

    path = lib.makeBinPath [
      pkgs.coreutils
      pkgs.gnused
      pkgs.gnugrep
    ];
  };

  src = ./extlinux-conf-builder.sh;
}
