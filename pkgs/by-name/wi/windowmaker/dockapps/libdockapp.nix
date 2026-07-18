{
  lib,
  stdenv,
  autoreconfHook,
  dockapps-sources,
  font-util,
  libx11,
  libxext,
  libxpm,
  mkfontdir,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  inherit (dockapps-sources) version src;
  pname = "libdockapp";

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    libx11
    libxext
    libxpm
    font-util
    mkfontdir
  ];

  # There is a bug on --with-font
  configureFlags = [
    "--with-examples=no"
    "--with-font=no"
  ];

  sourceRoot = "${finalAttrs.src.name}/libdockapp";

  meta = {
    description = "Library providing a framework for dockapps";
    homepage = "https://www.dockapps.net/libdockapp";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
  };
})
