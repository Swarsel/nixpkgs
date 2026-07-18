{
  lib,
  stdenv,
  fetchurl,
  adwaita-icon-theme,
  desktop-file-utils,
  gcr,
  gdk-pixbuf,
  gettext,
  gexiv2_0_16,
  glib,
  glib-networking,
  gnome,
  gobject-introspection,
  gsettings-desktop-schemas,
  gst_all_1,
  gtk3,
  itstool,
  json-glib,
  libexif,
  libgee,
  libgphoto2,
  libgudev,
  libheif,
  libportal-gtk3,
  libraw,
  librsvg,
  libsecret,
  libsoup_3,
  libwebp,
  libxml2,
  meson,
  ninja,
  pkg-config,
  sqlite,
  vala,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "shotwell";
  version = "0.32.17";

  src = fetchurl {
    url = "mirror://gnome/sources/shotwell/${lib.versions.majorMinor finalAttrs.version}/shotwell-${finalAttrs.version}.tar.xz";
    sha256 = "sha256-ClZoTpiBfDED9Upkj+lABCfHaiWnsRFFf8HYYMMWdnI=";
  };

  nativeBuildInputs = [
    meson
    ninja
    vala
    pkg-config
    itstool
    gettext
    desktop-file-utils
    wrapGAppsHook3
    gobject-introspection
  ];

  buildInputs = [
    gtk3
    libexif
    libgphoto2
    libwebp
    libsoup_3
    libxml2
    sqlite
    gst_all_1.gstreamer
    gst_all_1.gst-libav
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    libgee
    libgudev
    gexiv2_0_16
    gsettings-desktop-schemas
    libraw
    json-glib
    glib
    glib-networking
    gdk-pixbuf
    librsvg
    gcr
    adwaita-icon-theme
    libsecret
    libportal-gtk3
  ];

  postInstall = ''
    # Pull in HEIF support.
    # In postInstall to run before gappsWrapperArgsHook.
    export GDK_PIXBUF_MODULE_FILE="${
      gnome._gdkPixbufCacheBuilder_DO_NOT_USE {
        extraLoaders = [
          libheif.lib
        ];
      }
    }"
  '';

  passthru = {
    updateScript = gnome.updateScript {
      packageName = "shotwell";
      versionPolicy = "odd-unstable";
    };
  };

  meta = {
    description = "Popular photo organizer for the GNOME desktop";
    homepage = "https://gitlab.gnome.org/GNOME/shotwell";
    license = lib.licenses.lgpl21Plus;
    maintainers = with lib.maintainers; [ bobby285271 ];
    platforms = lib.platforms.linux;
    mainProgram = "shotwell";
  };
})
