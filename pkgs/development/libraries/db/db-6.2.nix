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
    version = "6.2.32";

    extraPatches = [
      ./clang-6.0.patch
      ./CVE-2017-10140-cwd-db_config.patch
      ./darwin-mutexes.patch
    ];

    license = lib.licenses.agpl3Only;
    sha256 = "1yx8wzhch5wwh016nh0kfxvknjkafv6ybkqh6nh7lxx50jqf5id9";
  }
)
