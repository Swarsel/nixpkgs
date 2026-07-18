{
  lib,
  stdenv,
  fetchurl,
  dvdauthor,
  gst_all_1,
  gtk3,
  hicolor-icon-theme,
  intltool,
  itstool,
  libburn,
  libcanberra-gtk3,
  libisofs,
  libnotify,
  libxml2,
  pkg-config,
  vcdimager,
  wrapGAppsHook3,
}:

let
  major = "3.12";
  minor = "3";
  binpath = lib.makeBinPath [
    dvdauthor
    vcdimager
  ];

in
stdenv.mkDerivation (finalAttrs: {
  pname = "brasero";
  version = "${major}.${minor}";

  src = fetchurl {
    url = "mirror://gnome/sources/brasero/${major}/brasero-${finalAttrs.version}.tar.xz";
    hash = "sha256-h3SerjOhQSB9GwC+IzttgEWYLtMkntS5ja4fOpdf6hU=";
  };

  # brasero checks that the applications it uses aren't symlinks, but this
  # will obviously not work on nix
  patches = [ ./remove-symlink-check.patch ];

  nativeBuildInputs = [
    pkg-config
    itstool
    intltool
    wrapGAppsHook3
  ];

  buildInputs = [
    gtk3
    libxml2
    libnotify
    libcanberra-gtk3
    libburn
    libisofs
    hicolor-icon-theme
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-ugly
    gst_all_1.gst-libav
  ];

  configureFlags = [
    "--with-girdir=$out/share/gir-1.0"
    "--with-typelibdir=$out/lib/girepository-1.0"
  ];

  env = lib.optionalAttrs stdenv.cc.isGNU {
    NIX_CFLAGS_COMPILE = "-Wno-error=incompatible-pointer-types";
  };

  preFixup = ''
    gappsWrapperArgs+=(--prefix PATH : "${binpath}")
  '';

  enableParallelBuilding = true;

  meta = {
    description = "Gnome CD/DVD Burner";
    homepage = "https://gitlab.gnome.org/GNOME/brasero";
    license = lib.licenses.gpl2Plus;
    maintainers = [ lib.maintainers.bdimcheff ];
    platforms = lib.platforms.linux;
    mainProgram = "brasero";
  };
})
