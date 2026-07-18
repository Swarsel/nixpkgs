{
  lib,
  stdenv,
  fetchFromGitLab,
  bash-completion,
  dbus,
  docbook-xsl-nons,
  docbook_xml_dtd_412,
  gettext,
  glib,
  gobject-introspection,
  gtk-doc,
  libgudev,
  libxml2,
  libxslt,
  meson,
  mesonEmulatorHook,
  ninja,
  nix-update-script,
  nixosTests,
  pkg-config,
  polkit,
  python3,
  systemd,
  umockdev,
  upower,
  wrapGAppsNoGuiHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "power-profiles-daemon";
  version = "0.30";

  src = fetchFromGitLab {
    owner = "upower";
    repo = "power-profiles-daemon";
    rev = finalAttrs.version;
    hash = "sha256-iQUhA46BEln8pyIBxM/MY7An8BzfiFjxZdR/tUIj4S4=";
    domain = "gitlab.freedesktop.org";
  };

  outputs = [
    "out"
    "devdoc"
  ];

  postPatch = ''
    patchShebangs --build \
      tests/integration-test.py \
      tests/unittest_inspector.py

    patchShebangs --host \
      src/powerprofilesctl
  '';

  strictDeps = true;

  nativeBuildInputs = [
    pkg-config
    meson
    ninja
    gettext
    gtk-doc
    docbook-xsl-nons
    docbook_xml_dtd_412
    libxml2 # for xmllint for stripping GResources
    libxslt # for xsltproc for building docs
    gobject-introspection
    wrapGAppsNoGuiHook
    # checkInput but checked for during the configuring
    (python3.pythonOnBuildForHost.withPackages (
      ps: with ps; [
        pygobject3
        dbus-python
        python-dbusmock
        argparse-manpage
        shtab
      ]
    ))
  ]
  ++ lib.optionals (!stdenv.buildPlatform.canExecute stdenv.hostPlatform) [
    mesonEmulatorHook
  ];

  buildInputs = [
    bash-completion
    libgudev
    systemd
    upower
    glib
    polkit
    # for cli tool
    (python3.withPackages (ps: [
      ps.pygobject3
    ]))
  ];

  mesonFlags = [
    "-Dsystemdsystemunitdir=${placeholder "out"}/lib/systemd/system"
    "-Dgtk_doc=true"
    "-Dpylint=disabled"
    "-Dzshcomp=${placeholder "out"}/share/zsh/site-functions"
    "-Dtests=${lib.boolToString (stdenv.buildPlatform.canExecute stdenv.hostPlatform)}"
  ];

  env.PKG_CONFIG_POLKIT_GOBJECT_1_POLICYDIR = "${placeholder "out"}/share/polkit-1/actions";
  doCheck = true;

  nativeCheckInputs = [
    umockdev
    dbus
  ];

  checkInputs = [
    umockdev
  ];

  postFixup = ''
    wrapGApp "$out/bin/powerprofilesctl"
  '';

  # Only need to wrap the Python tool (powerprofilectl)
  dontWrapGApps = true;

  passthru = {
    tests = {
      nixos = nixosTests.power-profiles-daemon;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Makes user-selected power profiles handling available over D-Bus";
    homepage = "https://gitlab.freedesktop.org/upower/power-profiles-daemon";
    changelog = "https://gitlab.freedesktop.org/upower/power-profiles-daemon/-/releases/${finalAttrs.version}";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      mvnetbiz
      picnoir
      lyndeno
    ];

    platforms = lib.platforms.linux;
    mainProgram = "powerprofilesctl";
  };
})
