{
  lib,
  fetchurl,
  fuse3,
  mkKdeDerivation,
  pkg-config,
}:
mkKdeDerivation rec {
  pname = "kio-fuse";
  version = "5.1.1";

  src = fetchurl {
    url = "mirror://kde/stable/kio-fuse/kio-fuse-${version}.tar.xz";
    hash = "sha256-rfaqfOBVwJh+cWqTrAHzwKl8EoBCFEPNayHg5x12PRQ=";
  };

  extraBuildInputs = [ fuse3 ];
  extraNativeBuildInputs = [ pkg-config ];
  meta.license = with lib.licenses; [ gpl3Plus ];
}
