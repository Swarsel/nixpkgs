pkgs: {
  percona-xtrabackup = pkgs.percona-xtrabackup_8_4;
  percona-xtrabackup_8_4 = pkgs.callPackage ./8_4.nix { };
}
