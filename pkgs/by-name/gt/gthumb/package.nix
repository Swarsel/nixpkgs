{
  lib,
  stdenv,
  fetchurl,
  bison,
  brasero,
  clutter-gtk,
  colord,
  desktop-file-utils,
  exiv2,
  flex,
  glib,
  gnome,
  gsettings-desktop-schemas,
  gst_all_1,
  gtk3,
  itstool,
  lcms2,
  libheif,
  libjpeg,
  libjxl,
  libraw,
  librsvg,
  libtiff,
  libwebp,
  libx11,
  meson,
  ninja,
  pkg-config,
  python3,
  shared-mime-info,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gthumb";
  version = "3.12.10";

  src = fetchurl {
    url = "mirror://gnome/sources/gthumb/${lib.versions.majorMinor finalAttrs.version}/gthumb-${finalAttrs.version}.tar.xz";
    sha256 = "sha256-MiI0RlPNb7XXmBtzlRrj2QxBT3QiCoschmWyVXQoTHU=";
  };

  postPatch = ''
    chmod +x gthumb/make-gthumb-h.py

    patchShebangs data/gschemas/make-enums.py \
      gthumb/make-gthumb-h.py \
      po/make-potfiles-in.py \
      gthumb/make-authors-tab.py
  '';

  strictDeps = true;

  nativeBuildInputs = [
    bison
    desktop-file-utils
    flex
    itstool
    meson
    ninja
    pkg-config
    python3
    wrapGAppsHook3
  ];

  buildInputs = [
    brasero
    clutter-gtk
    colord
    exiv2
    glib
    gsettings-desktop-schemas
    gst_all_1.gst-plugins-base
    (gst_all_1.gst-plugins-good.override { gtkSupport = true; })
    gst_all_1.gst-libav
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-ugly
    gtk3
    lcms2
    libheif
    libjpeg
    libjxl
    libraw
    librsvg
    libtiff
    libwebp
    libx11
  ];

  preFixup = ''
    gappsWrapperArgs+=(--prefix XDG_DATA_DIRS : "${shared-mime-info}/share")
  '';

  passthru = {
    updateScript = gnome.updateScript {
      packageName = "gthumb";
      versionPolicy = "odd-unstable";
    };
  };

  meta = {
    description = "Image browser and viewer for GNOME";
    homepage = "https://gitlab.gnome.org/GNOME/gthumb";
    license = lib.licenses.gpl2Plus;

    maintainers = with lib.maintainers; [
      bobby285271
      mimame
    ];

    platforms = lib.platforms.linux;
    mainProgram = "gthumb";
  };
})
