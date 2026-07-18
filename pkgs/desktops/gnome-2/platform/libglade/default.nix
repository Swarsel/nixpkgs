{
  lib,
  stdenv,
  fetchurl,
  gettext,
  gtk2,
  libxml2,
  pkg-config,
}:

stdenv.mkDerivation rec {
  pname = "libglade";
  version = "2.6.4";

  src = fetchurl {
    url = "mirror://gnome/sources/libglade/${lib.versions.majorMinor version}/libglade-${version}.tar.bz2";
    sha256 = "1v2x2s04jry4gpabws92i0wq2ghd47yr5n9nhgnkd7c38xv1wdk4";
  };

  outputs = [
    "out"
    "dev"
  ];

  postPatch = ''
    # uses pkg-config in some places and uses the correct $PKG_CONFIG in some
    # it's an ancient library so it has very old configure scripts and m4
    substituteInPlace ./configure \
      --replace "pkg-config" "$PKG_CONFIG"
  '';

  strictDeps = true;

  nativeBuildInputs = [
    pkg-config
    gettext
  ];

  buildInputs = [ gtk2 ];
  propagatedBuildInputs = [ libxml2 ];
  env.NIX_LDFLAGS = "-lgmodule-2.0";
}
