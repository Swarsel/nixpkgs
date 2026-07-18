{
  lib,
  stdenv,
  autoreconfHook,
  dbus,
  docbook_xsl,
  fetchgit,
  gitUpdater,
  glib,
  gnome-common,
  gobject-introspection,
  gtk-doc,
  libgtop,
  libstartup_notification,
  libwnck,
  pkg-config,
  python3,
  vala,
  which,
  wrapGAppsHook3,
  xorg-server,
  withDocs ? stdenv.buildPlatform.canExecute stdenv.hostPlatform,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "bamf";
  version = "0.5.6";

  src = fetchgit {
    url = "https://git.launchpad.net/~unity-team/bamf";
    tag = finalAttrs.version;
    sha256 = "7U+2GcuDjPU8quZjkd8bLADGlG++tl6wSo0mUQkjAXQ=";
  };

  outputs = [
    "out"
    "dev"
  ]
  ++ lib.optionals withDocs [
    "devdoc"
  ];

  # Fix hard-coded path
  # https://bugs.launchpad.net/bamf/+bug/1780557
  postPatch = ''
    substituteInPlace data/Makefile.am \
      --replace '/usr/lib/systemd/user' '@prefix@/lib/systemd/user'
  '';

  strictDeps = true;

  nativeBuildInputs = [
    (python3.pythonOnBuildForHost.withPackages (ps: with ps; [ lxml ])) # Tests
    autoreconfHook
    dbus
    docbook_xsl
    gnome-common
    gobject-introspection
    gtk-doc # required for autoreconfHook, even when `withDocs = false`
    pkg-config
    vala
    which
    wrapGAppsHook3
    xorg-server
  ];

  buildInputs = [
    glib
    libgtop
    libstartup_notification
    libwnck
  ];

  configureFlags = [
    "--enable-headless-tests"
  ]
  ++ lib.optionals withDocs [
    "--enable-gtk-doc"
  ];

  # Fix paths
  makeFlags = [
    "INTROSPECTION_GIRDIR=${placeholder "dev"}/share/gir-1.0/"
    "INTROSPECTION_TYPELIBDIR=${placeholder "out"}/lib/girepository-1.0"
  ];

  # Ignore deprecation errors
  env.NIX_CFLAGS_COMPILE = "-DGLIB_DISABLE_DEPRECATION_WARNINGS";
  # TODO: Requires /etc/machine-id
  doCheck = false;

  depsBuildBuild = [
    pkg-config
  ];

  passthru.updateScript = gitUpdater {
    ignoredVersions = ".ubuntu.*";
  };

  meta = {
    description = "Application matching framework";

    longDescription = ''
      Removes the headache of applications matching
      into a simple DBus daemon and c wrapper library.
    '';

    homepage = "https://launchpad.net/bamf";
    license = lib.licenses.lgpl3;
    maintainers = with lib.maintainers; [ davidak ];
    platforms = lib.platforms.linux;
    teams = [ lib.teams.pantheon ];
  };
})
