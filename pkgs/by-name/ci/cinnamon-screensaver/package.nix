{
  lib,
  stdenv,
  fetchFromGitHub,
  cairo,
  caribou,
  cinnamon,
  cinnamon-desktop,
  dbus,
  gettext,
  glib,
  gobject-introspection,
  gtk3,
  intltool,
  iso-flags-png-320x240,
  libgnomekbd,
  libtool,
  libx11,
  libxext,
  libxinerama,
  libxrandr,
  libxslt,
  meson,
  ninja,
  pam,
  pkg-config,
  python3,
  wrapGAppsHook3,
  xdotool,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cinnamon-screensaver";
  version = "6.6.1";

  src = fetchFromGitHub {
    owner = "linuxmint";
    repo = "cinnamon-screensaver";
    tag = finalAttrs.version;
    hash = "sha256-NK33cIrcTicLs59eJ550FghjuWS93yD642ObAS55Dtk=";
  };

  patches = [
    # Do not override GI_TYPELIB_PATH set by wrapGAppsHook3.
    # https://github.com/linuxmint/cinnamon-screensaver/pull/456#discussion_r1702738776.
    ./preserve-existing-gi-typelib-path.patch
  ];

  postPatch = ''
    # cscreensaver hardcodes absolute paths everywhere. Nuke from orbit.
    find . -type f -exec sed -i \
      -e s,/usr/share/locale,/run/current-system/sw/share/locale,g \
      -e s,/usr/share/iso-flag-png,${iso-flags-png-320x240}/share/iso-flags-png,g \
      {} +
  '';

  nativeBuildInputs = [
    pkg-config
    wrapGAppsHook3
    gettext
    intltool
    dbus # for meson.build
    libxslt
    libtool
    meson
    ninja
    gobject-introspection
  ];

  buildInputs = [
    # from meson.build
    gtk3
    glib

    libxext
    libxinerama
    libx11
    libxrandr

    (python3.withPackages (
      pp: with pp; [
        pygobject3
        setproctitle
        python-xapp
        pycairo
      ]
    ))
    xdotool
    pam
    cairo
    cinnamon-desktop
    cinnamon
    libgnomekbd
    caribou
  ];

  preFixup = ''
    # https://github.com/NixOS/nixpkgs/issues/101881
    gappsWrapperArgs+=(
      --prefix XDG_DATA_DIRS : "${caribou}/share"
    )
  '';

  postFixup = ''
    # Shared objects can't be wrapped.
    mv $out/libexec/cinnamon-screensaver/{.libcscreensaver.so-wrapped,libcscreensaver.so}
  '';

  meta = {
    description = "Cinnamon screen locker and screensaver program";
    homepage = "https://github.com/linuxmint/cinnamon-screensaver";

    license = [
      lib.licenses.gpl2
      lib.licenses.lgpl2
    ];

    platforms = lib.platforms.linux;
    teams = [ lib.teams.cinnamon ];
  };
})
