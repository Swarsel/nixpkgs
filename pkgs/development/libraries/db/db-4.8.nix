{
  lib,
  stdenv,
  fetchurl,
  autoconf269,
  autoreconfHook,
  fetchpatch,
  ...
}@args:

import ./generic.nix (
  args
  // {
    version = "4.8.30";
    drvArgs.doCheck = false;
    drvArgs.hardeningDisable = [ "format" ];

    extraPatches = [
      ./clang-4.8.patch
      ./CVE-2017-10140-4.8-cwd-db_config.patch
      ./darwin-mutexes-4.8.patch
    ];

    sha256 = "0ampbl2f0hb1nix195kz1syrqqxpmvnvnfvphambj7xjrl3iljg0";
  }
)
