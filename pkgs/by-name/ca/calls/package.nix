{
  lib,
  stdenv,
  fetchFromGitLab,
  appstream-glib,
  bubblewrap,
  callaudiod,
  dbus,
  desktop-file-utils,
  docbook-xsl-nons,
  docbook_xml_dtd_43,
  docutils,
  evolution-data-server-gtk4,
  feedbackd,
  folks,
  gom,
  gsound,
  gst_all_1,
  gtk-doc,
  gtk4,
  libadwaita,
  libpeas2,
  libsecret,
  meson,
  mesonEmulatorHook,
  modemmanager,
  ninja,
  pkg-config,
  shared-mime-info,
  sofia_sip,
  vala,
  wrapGAppsHook4,
  writeShellScriptBin,
  xvfb-run,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "calls";
  version = "49.1.1";

  src = fetchFromGitLab {
    owner = "GNOME";
    repo = "calls";
    rev = "v${finalAttrs.version}";
    hash = "sha256-fqvfzdk1szNFm4aRRGNDaA/AmjJdQjBsMhvEolEetE0=";
    fetchSubmodules = true;
    domain = "gitlab.gnome.org";
  };

  outputs = [
    "out"
    "devdoc"
  ];

  strictDeps = true;

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    desktop-file-utils
    appstream-glib
    vala
    wrapGAppsHook4
    gtk-doc
    docbook-xsl-nons
    docbook_xml_dtd_43
    docutils
  ]
  ++ lib.optionals (!stdenv.buildPlatform.canExecute stdenv.hostPlatform) [
    mesonEmulatorHook
  ];

  buildInputs = [
    modemmanager
    libadwaita
    libsecret
    evolution-data-server-gtk4 # UI part not needed, using gtk4 variant (over the default of gtk3) to reduce closure.
    folks
    gom
    gsound
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-ugly
    feedbackd
    callaudiod
    gtk4
    libpeas2
    sofia_sip
  ];

  mesonFlags = [
    (lib.mesonBool "gtk_doc" true)
    (lib.mesonBool "tests" finalAttrs.finalPackage.doCheck)
  ];

  doCheck = true;

  nativeCheckInputs = [
    (writeShellScriptBin "dbus-run-session" ''
      # tests invoke `dbus-run-session` directly, but without the necessary `--config-file` argument
      exec ${lib.getExe' dbus "dbus-run-session"} --config-file=${dbus}/share/dbus-1/session.conf "$@"
    '')
    bubblewrap
    dbus
    shared-mime-info
    xvfb-run
  ];

  checkPhase = ''
    runHook preCheck

    HOME=$(mktemp -d) \
    xvfb-run -s '-screen 0 800x600x24' \
      bwrap --unshare-uts --hostname 127.0.0.1 --dev-bind / / \
      meson test --no-rebuild --print-errorlogs

    runHook postCheck
  '';

  preFixup = ''
    gappsWrapperArgs+=(--prefix XDG_DATA_DIRS : "${shared-mime-info}/share")
  '';

  meta = {
    description = "Phone dialer and call handler";
    longDescription = "GNOME Calls is a phone dialer and call handler. Setting NixOS option `programs.calls.enable = true` is recommended.";
    homepage = "https://gitlab.gnome.org/GNOME/calls";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ craigem ];
    platforms = lib.platforms.linux;
    mainProgram = "gnome-calls";
  };
})
