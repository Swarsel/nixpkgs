{
  lib,
  stdenv,
  mkDerivation,
}:
# this package is quite different from stock libcxxrt.
# as of FreeBSD 14.0, it is vendored from APPROXIMATELY libcxxrt
# 5d8a15823a103bbc27f1bfdcf2b5aa008fab57dd, though the vendoring mechanism is
# extremely ad-hoc. Moreover, the build mechanism is totally custom, and adds
# symbol versions not specified on any version of libcxxrt.
mkDerivation {
  pname = "libcxxrt";

  outputs = [
    "out"
    "dev"
    "debug"
  ];

  # they already fixed the undefined symbols in the version map upstream. it'll be released probably in 15.0
  preBuild = ''
    export NIX_LDFLAGS="$NIX_LDFLAGS --undefined-version"
  '';

  extraPaths = [ "contrib/libcxxrt" ];
  libName = "cxxrt";
  noLibcxx = true;
  path = "lib/libcxxrt";
}
