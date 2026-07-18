{
  lib,
  stdenv,
  fetchurl,
  at-spi2-core,
  babl,
  dbus,
  desktop-file-utils,
  dleyna,
  gdk-pixbuf,
  gegl,
  geocode-glib_2,
  gettext,
  gexiv2,
  glib,
  gnome,
  gnome-online-accounts,
  gobject-introspection,
  gsettings-desktop-schemas,
  gtk3,
  itstool,
  libdazzle,
  libhandy,
  libportal-gtk3,
  libxml2,
  localsearch,
  meson,
  ninja,
  nixosTests,
  pkg-config,
  python3,
  tinysparql,
  wrapGAppsHook3,
}:

stdenv.mkDerivation rec {
  pname = "gnome-photos";
  version = "44.0";

  src = fetchurl {
    url = "mirror://gnome/sources/gnome-photos/${lib.versions.major version}/gnome-photos-${version}.tar.xz";
    sha256 = "544hA5fTxigJxs1VIdpuzLShHd6lvyr4YypH9Npcgp4=";
  };

  outputs = [
    "out"
    "installedTests"
  ];

  patches = [
    ./installed-tests-path.patch
  ];

  postPatch = ''
    chmod +x meson_post_install.py
    patchShebangs meson_post_install.py
    patchShebangs tests/basic.py
  '';

  nativeBuildInputs = [
    desktop-file-utils
    gettext
    gobject-introspection # for setup hook
    glib # for setup hook
    itstool
    libxml2
    meson
    ninja
    pkg-config
    (python3.withPackages (
      pkgs: with pkgs; [
        dogtail
        pygobject3
        pyatspi
      ]
    ))
    wrapGAppsHook3
  ];

  buildInputs = [
    babl
    dbus
    dleyna
    gdk-pixbuf
    gegl
    geocode-glib_2
    gexiv2
    glib
    gnome-online-accounts
    gsettings-desktop-schemas
    gtk3
    libdazzle
    libportal-gtk3
    libhandy
    tinysparql
    localsearch # For 'org.freedesktop.Tracker.Miner.Files' GSettings schema

    at-spi2-core # for tests
  ];

  mesonFlags = [
    "-Dinstalled_tests=true"
    "-Dinstalled_test_prefix=${placeholder "installedTests"}"
  ];

  postFixup = ''
    wrapGApp "${placeholder "installedTests"}/libexec/installed-tests/gnome-photos/basic.py"
  '';

  passthru = {
    tests = {
      installed-tests = nixosTests.installed-tests.gnome-photos;
    };

    updateScript = gnome.updateScript {
      packageName = pname;
    };
  };

  meta = {
    description = "Access, organize and share your photos";
    homepage = "https://gitlab.gnome.org/GNOME/gnome-photos";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    mainProgram = "gnome-photos";
    teams = [ lib.teams.gnome ];
  };
}
