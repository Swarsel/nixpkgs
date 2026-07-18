{
  lib,
  stdenv,
  fetchFromGitHub,
  cairo,
  dbus,
  file,
  gdk-pixbuf,
  glib,
  gobject-introspection,
  gtk3,
  inxi,
  libdbusmenu-gtk3,
  libgnomekbd,
  libxkbfile,
  mate-panel,
  meson,
  ninja,
  pkg-config,
  python3,
  vala,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "xapp";
  version = "3.2.2";

  src = fetchFromGitHub {
    owner = "linuxmint";
    repo = "xapp";
    rev = finalAttrs.version;
    hash = "sha256-xVGIrK7koqX6xKoanVHWQMBUusUjtvHzQg2OV0E0b78=";
  };

  outputs = [
    "out"
    "dev"
  ];

  postPatch = ''
    chmod +x schemas/meson_install_schemas.py # patchShebangs requires executable file
    patchShebangs schemas/meson_install_schemas.py

    # Used in cinnamon-settings
    substituteInPlace scripts/upload-system-info \
      --replace-fail "'/usr/bin/pastebin'" "'$out/bin/pastebin'" \
      --replace-fail "'inxi'" "'${inxi}/bin/inxi'"

    # Used in x-d-p-xapp
    substituteInPlace scripts/xfce4-set-wallpaper \
      --replace-fail "file --mime-type" "${file}/bin/file --mime-type"
  '';

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    python3
    vala
    wrapGAppsHook3
    gobject-introspection
  ];

  buildInputs = [
    (python3.withPackages (
      ps: with ps; [
        pygobject3
        setproctitle # mate applet
      ]
    ))
    libgnomekbd
    gdk-pixbuf
    libxkbfile
    python3.pkgs.pygobject3 # for .pc file
    mate-panel # for gobject-introspection
    dbus
    libdbusmenu-gtk3
  ];

  # Requires in xapp.pc
  propagatedBuildInputs = [
    gtk3
    cairo
    glib
  ];

  mesonFlags = [
    "-Dpy-overrides-dir=${placeholder "out"}/${python3.sitePackages}/gi/overrides"
  ];

  # Fix gtk3 module target dir. Proper upstream solution should be using define_variable.
  env.PKG_CONFIG_GTK__3_0_LIBDIR = "${placeholder "out"}/lib";

  preFixup = ''
    wrapGApp $out/lib/xapps/xapp-sn-watcher
  '';

  # Recommended by upstream, which enables the build of xapp-debug.
  # https://github.com/linuxmint/xapp/issues/169#issuecomment-1574962071
  mesonBuildType = "debugoptimized";

  meta = {
    description = "Cross-desktop libraries and common resources";
    homepage = "https://github.com/linuxmint/xapp";
    license = lib.licenses.lgpl3;
    platforms = lib.platforms.linux;
    teams = [ lib.teams.cinnamon ];
  };
})
