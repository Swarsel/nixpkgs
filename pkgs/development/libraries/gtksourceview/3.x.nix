{
  lib,
  stdenv,
  fetchurl,
  atk,
  cairo,
  dbus,
  gettext,
  glib,
  gobject-introspection,
  gtk3,
  intltool,
  libxml2,
  pango,
  perl,
  pkg-config,
  shared-mime-info,
  testers,
  vala,
  xvfb-run,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gtksourceview";
  version = "3.24.11";

  src =
    let
      inherit (finalAttrs) pname version;
    in
    fetchurl {
      url = "mirror://gnome/sources/${pname}/${lib.versions.majorMinor version}/${pname}-${version}.tar.xz";
      sha256 = "1zbpj283b5ycz767hqz5kdq02wzsga65pp4fykvhg8xj6x50f6v9";
    };

  outputs = [
    "out"
    "dev"
  ];

  patches = [ ./3.x-nix_share_path.patch ];

  nativeBuildInputs = [
    pkg-config
    intltool
    perl
    gobject-introspection
    vala
  ];

  buildInputs = [
    atk
    cairo
    glib
    pango
    libxml2
    gettext
  ];

  propagatedBuildInputs = [
    # Required by gtksourceview-3.0.pc
    gtk3
    # Used by gtk_source_language_manager_guess_language
    shared-mime-info
  ];

  env = lib.optionalAttrs stdenv.cc.isGNU {
    NIX_CFLAGS_COMPILE = "-Wno-error=incompatible-pointer-types";
  };

  preBuild = ''
    substituteInPlace gtksourceview/gtksourceview-utils.c --replace "@NIX_SHARE_PATH@" "$out/share"
  '';

  doCheck = stdenv.hostPlatform.isLinux;

  nativeCheckInputs = [
    xvfb-run
    dbus
  ];

  checkPhase = ''
    NO_AT_BRIDGE=1 \
    XDG_DATA_DIRS="$XDG_DATA_DIRS:${shared-mime-info}/share" \
    xvfb-run -s '-screen 0 800x600x24' dbus-run-session \
      --config-file=${dbus}/share/dbus-1/session.conf \
      make check
  '';

  enableParallelBuilding = true;
  passthru.tests.pkg-config = testers.testMetaPkgConfig finalAttrs.finalPackage;

  meta = {
    homepage = "https://gitlab.gnome.org/GNOME/gtksourceview";
    license = lib.licenses.lgpl21;
    platforms = with lib.platforms; linux ++ darwin;
    pkgConfigModules = [ "gtksourceview-3.0" ];
    teams = [ lib.teams.gnome ];
  };
})
