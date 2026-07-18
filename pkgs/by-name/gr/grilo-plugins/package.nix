{
  lib,
  stdenv,
  fetchurl,
  avahi,
  dleyna,
  gettext,
  glib,
  gmime,
  gnome,
  gnome-online-accounts,
  gom,
  gperf,
  grilo,
  gst_all_1,
  itstool,
  json-glib,
  libarchive,
  libdmapsharing,
  libmediaart,
  liboauth,
  librest,
  libsoup_3,
  libxml2,
  localsearch,
  lua5_4,
  meson,
  ninja,
  pkg-config,
  replaceVars,
  sqlite,
  tinysparql,
  totem-pl-parser,
}:

stdenv.mkDerivation rec {
  pname = "grilo-plugins";
  version = "0.3.18";

  src = fetchurl {
    url = "mirror://gnome/sources/grilo-plugins/${lib.versions.majorMinor version}/grilo-plugins-${version}.tar.xz";
    sha256 = "jjznTucXw8Mi0MsPjfJrsJFAKKXQFuKAVf+0nMmkbF4=";
  };

  patches = [
    # grl-chromaprint requires the following GStreamer elements:
    # * fakesink (gstreamer)
    # * playbin (gst-plugins-base)
    # * chromaprint (gst-plugins-bad)
    (replaceVars ./chromaprint-gst-plugins.patch {
      load_plugins =
        lib.concatMapStrings
          (plugin: ''gst_registry_scan_path(gst_registry_get(), "${lib.getLib plugin}/lib/gstreamer-1.0");'')
          (
            with gst_all_1;
            [
              gstreamer
              gst-plugins-base
              gst-plugins-bad
            ]
          );
    })
  ];

  strictDeps = true;

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    gettext
    itstool
    gperf # for lua-factory
    glib # glib-compile-resources
    localsearch
  ];

  buildInputs = [
    grilo
    libxml2
    lua5_4
    liboauth
    sqlite
    gnome-online-accounts
    totem-pl-parser
    libarchive
    libdmapsharing
    libsoup_3
    librest
    gmime
    gom
    json-glib
    avahi
    libmediaart
    tinysparql
    dleyna
    gst_all_1.gstreamer
  ];

  depsBuildBuild = [
    pkg-config
  ];

  passthru = {
    updateScript = gnome.updateScript {
      packageName = pname;
      versionPolicy = "none";
    };
  };

  meta = {
    description = "Collection of plugins for the Grilo framework";
    homepage = "https://gitlab.gnome.org/GNOME/grilo-plugins";
    license = lib.licenses.lgpl21Plus;
    platforms = lib.platforms.unix;
    teams = [ lib.teams.gnome ];
  };
}
