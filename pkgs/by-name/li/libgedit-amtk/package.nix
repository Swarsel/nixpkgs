{
  lib,
  stdenv,
  fetchFromGitLab,
  dbus,
  docbook-xsl-nons,
  gitUpdater,
  glib,
  gobject-introspection,
  gtk-doc,
  gtk3,
  meson,
  mesonEmulatorHook,
  ninja,
  pkg-config,
  xvfb-run,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libgedit-amtk";
  version = "5.10.0";

  src = fetchFromGitLab {
    owner = "gedit";
    repo = "libgedit-amtk";
    tag = finalAttrs.version;
    hash = "sha256-wA5KRA1qWJzw5JRXQL/kP2BgCQiNhf6aIe6RppBEH90=";
    domain = "gitlab.gnome.org";
    forceFetchGit = true; # To avoid occasional 501 failures.
    group = "World";
  };

  outputs = [
    "out"
    "dev"
    "devdoc"
  ];

  strictDeps = true;

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    gobject-introspection
    gtk-doc
    docbook-xsl-nons
  ]
  ++ lib.optionals (!stdenv.buildPlatform.canExecute stdenv.hostPlatform) [
    mesonEmulatorHook
  ];

  propagatedBuildInputs = [
    # Required by libgedit-amtk-5.pc
    glib
    gtk3
  ];

  doCheck = stdenv.hostPlatform.isLinux;

  nativeCheckInputs = [
    dbus # For dbus-run-session
  ];

  checkPhase = ''
    runHook preCheck

    export NO_AT_BRIDGE=1
    ${xvfb-run}/bin/xvfb-run -s '-screen 0 800x600x24' dbus-run-session \
      --config-file=${dbus}/share/dbus-1/session.conf \
      meson test --print-errorlogs

    runHook postCheck
  '';

  passthru.updateScript = gitUpdater { ignoredVersions = "(alpha|beta|rc).*"; };

  meta = {
    description = "Actions, Menus and Toolbars Kit for GTK applications";
    homepage = "https://gitlab.gnome.org/World/gedit/libgedit-amtk";
    changelog = "https://gitlab.gnome.org/World/gedit/libgedit-amtk/-/blob/${finalAttrs.version}/NEWS?ref_type=tags";
    license = lib.licenses.lgpl21Plus;

    maintainers = with lib.maintainers; [
      bobby285271
    ];

    platforms = lib.platforms.linux;
  };
})
