{ buildPackages, mkDerivation }:
mkDerivation {
  LUA = "${buildPackages.lua}/bin/lua";

  extraPaths = [
    "tools/lua"
    "lib/libc/Versions.def"
  ];

  path = "lib/libifconfig";
}
