{
  lib,
  stdenv,
  fetchFromGitHub,
  glib,
  libglibutil,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libgbinder";
  version = "1.1.45";

  src = fetchFromGitHub {
    owner = "mer-hybris";
    repo = "libgbinder";
    rev = finalAttrs.version;
    sha256 = "sha256-YOkId2FlLSc+UZ+q8X8E2RwE3QlqBJOS7sjVviwwKJM=";
  };

  outputs = [
    "out"
    "dev"
  ];

  postPatch = ''
    # Fix pkg-config and ranlib names for cross-compilation
    substituteInPlace Makefile \
      --replace "pkg-config" "$PKG_CONFIG" \
      --replace "ranlib" "$RANLIB"
  '';

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    glib
    libglibutil
  ];

  makeFlags = [
    "LIBDIR=$(out)/lib"
    "INSTALL_INCLUDE_DIR=$(dev)/include/gbinder"
    "INSTALL_PKGCONFIG_DIR=$(dev)/lib/pkgconfig"
  ];

  postInstall = ''
    sed -i -e "s@includedir=/usr@includedir=$dev@g" $dev/lib/pkgconfig/$pname.pc
    sed -i -e "s@Cflags: @Cflags: $($PKG_CONFIG --cflags libglibutil) @g" $dev/lib/pkgconfig/$pname.pc
  '';

  installTargets = [
    "install"
    "install-dev"
  ];

  meta = {
    description = "GLib-style interface to binder";
    homepage = "https://github.com/mer-hybris/libgbinder";
    license = lib.licenses.bsd3;
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };
})
