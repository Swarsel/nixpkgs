{
  lib,
  stdenv,
  fetchFromGitHub,
  glib,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libglibutil";
  version = "1.0.82";

  src = fetchFromGitHub {
    owner = "sailfishos";
    repo = "libglibutil";
    rev = finalAttrs.version;
    sha256 = "sha256-etFvEqU3WeXkImRhXgEw0Pd2gZvuQK4Sy4pIIyuazqc=";
  };

  outputs = [
    "out"
    "dev"
  ];

  postPatch = ''
    # Fix pkg-config name for cross-compilation
    substituteInPlace Makefile --replace "pkg-config" "$PKG_CONFIG"
  '';

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    glib
  ];

  makeFlags = [
    "LIBDIR=$(out)/lib"
    "INSTALL_INCLUDE_DIR=$(dev)/include/gutil"
    "INSTALL_PKGCONFIG_DIR=$(dev)/lib/pkgconfig"
  ];

  postInstall = ''
    sed -i -e "s@includedir=/usr@includedir=$dev@g" $dev/lib/pkgconfig/$pname.pc
    sed -i -e "s@Cflags: @Cflags: $($PKG_CONFIG --cflags glib-2.0) @g" $dev/lib/pkgconfig/$pname.pc
  '';

  installTargets = [
    "install"
    "install-dev"
  ];

  meta = {
    description = "Library of glib utilities";
    homepage = "https://git.sailfishos.org/mer-core/libglibutil";
    license = lib.licenses.bsd3;
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };
})
