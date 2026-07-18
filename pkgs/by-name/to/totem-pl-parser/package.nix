{
  lib,
  stdenv,
  fetchurl,
  fetchpatch,
  gettext,
  glib,
  gnome,
  gobject-introspection,
  libxml2,
  meson,
  ninja,
  pkg-config,
}:

stdenv.mkDerivation rec {
  pname = "totem-pl-parser";
  version = "3.26.7";

  src = fetchurl {
    url = "mirror://gnome/sources/totem-pl-parser/${lib.versions.majorMinor version}/totem-pl-parser-${version}.tar.xz";
    sha256 = "YNUXwayr5UrjN/ZEUSZPx2cwaW6q4mtUgPs3FmaJtfM=";
  };

  patches = [
    # Upstream MR: https://gitlab.gnome.org/GNOME/totem-pl-parser/-/merge_requests/46
    (fetchpatch {
      sha256 = "sha256-Uya5fgFgauv5rIpVK3CDGCieyMus7VjcLMMe/vQ2WWY=";
      url = "https://gitlab.gnome.org/GNOME/totem-pl-parser/-/commit/f4f69c9b99095416aaed18a73f7486ad9eb04aa9.patch";
    })
  ];

  strictDeps = true;

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    gettext
    glib
    gobject-introspection
  ];

  buildInputs = [
    libxml2
    glib
  ];

  mesonFlags = lib.optionals (stdenv.buildPlatform != stdenv.hostPlatform) [
    "-Dintrospection=false"
  ];

  depsBuildBuild = [ pkg-config ];

  passthru = {
    updateScript = gnome.updateScript {
      packageName = pname;
      versionPolicy = "odd-unstable";
    };
  };

  meta = {
    description = "Simple GObject-based library to parse and save a host of playlist formats";
    homepage = "https://gitlab.gnome.org/GNOME/totem-pl-parser";
    license = lib.licenses.lgpl2;
    platforms = lib.platforms.unix;
    teams = [ lib.teams.gnome ];
  };
}
