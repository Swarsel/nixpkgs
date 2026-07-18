{
  lib,
  stdenv,
  fetchurl,
  gnome,
  gtk3,
  intltool,
  libxml2,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gdl";
  version = "3.40.0";

  src = fetchurl {
    url = "mirror://gnome/sources/gdl/${lib.versions.majorMinor finalAttrs.version}/gdl-${finalAttrs.version}.tar.xz";
    sha256 = "NkHU/WadHhgYrv88+f+3iH/Fw2eFC3jCjHdeukq2pVU=";
  };

  nativeBuildInputs = [
    pkg-config
    intltool
  ];

  buildInputs = [
    libxml2
    gtk3
  ];

  env = lib.optionalAttrs stdenv.cc.isGNU {
    # https://gitlab.gnome.org/Archive/gdl/-/issues/9
    NIX_CFLAGS_COMPILE = "-Wno-error=incompatible-pointer-types";
  };

  passthru = {
    updateScript = gnome.updateScript {
      packageName = "gdl";
    };
  };

  meta = {
    description = "Gnome docking library";
    homepage = "https://developer.gnome.org/gdl/";
    license = lib.licenses.gpl2;
    platforms = lib.platforms.unix;
    teams = [ lib.teams.gnome ];
  };
})
