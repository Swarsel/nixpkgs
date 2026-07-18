{
  lib,
  stdenv,
  fetchFromGitLab,
  appstream,
  callaudiod,
  dbus,
  docutils,
  evince,
  evolution-data-server,
  feedbackd,
  gcr,
  gi-docgen,
  glib,
  gmobile,
  gnome-bluetooth,
  gnome-control-center,
  gnome-desktop,
  gnome-session,
  gnome-shell,
  gobject-introspection,
  gtk4,
  libadwaita,
  libgudev,
  libhandy,
  libsecret,
  libxkbcommon,
  meson,
  modemmanager,
  networkmanager,
  ninja,
  nix-update-script,
  nixosTests,
  pam,
  phoc,
  pkg-config,
  polkit,
  pulseaudio,
  python3,
  qrcodegen,
  systemd,
  upower,
  wayland,
  wayland-scanner,
  wrapGAppsHook4,
  xvfb-run,
}:

let
  # Derived from subprojects/libcall-ui.wrap
  libcall-ui = fetchFromGitLab {
    domain = "gitlab.gnome.org";
    # Workaround for https://github.com/NixOS/nixpkgs/issues/485701
    forceFetchGit = true;
    group = "World";
    hash = "sha256-4lSTwSRZditK51N/4s3tmIOgffe5+WyKxVq2IGqWRn4=";
    owner = "Phosh";
    repo = "libcall-ui";
    tag = "v0.1.5";
  };

  # Derived from subprojects/gvc.wrap
  gvc = fetchFromGitLab {
    domain = "gitlab.gnome.org";
    # Workaround for https://github.com/NixOS/nixpkgs/issues/485701
    forceFetchGit = true;
    hash = "sha256-10n441b7m/mvQRdrmEsxGxqjKUWzjGvnzJy256NZN5s=";
    owner = "GNOME";
    repo = "libgnome-volume-control";
    rev = "d2442f455844e5292cb4a74ffc66ecc8d7595a9f";
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "phosh";
  version = "0.54.0";

  src = fetchFromGitLab {
    owner = "Phosh";
    repo = "phosh";
    tag = "v${finalAttrs.version}";
    hash = "sha256-gByZRyUe17JY5imgtRdubJl1VH1JxlzmDQkHOtEIvj8=";
    domain = "gitlab.gnome.org";
    # Workaround for https://github.com/NixOS/nixpkgs/issues/485701
    forceFetchGit = true;
    group = "World";
  };

  postPatch = ''
    ln -s ${libcall-ui} subprojects/libcall-ui
    ln -s ${gvc} subprojects/gvc
  '';

  nativeBuildInputs = [
    libadwaita
    meson
    ninja
    pkg-config
    python3
    wayland-scanner
    wrapGAppsHook4
    docutils
    gi-docgen
  ];

  buildInputs = [
    evince
    phoc
    libhandy
    libsecret
    libxkbcommon
    libgudev
    callaudiod
    evolution-data-server
    pulseaudio
    modemmanager
    gcr
    networkmanager
    polkit
    gmobile
    gnome-bluetooth
    gnome-control-center
    gnome-desktop
    gnome-session
    gtk4
    pam
    systemd
    upower
    wayland
    feedbackd
    appstream
    qrcodegen
    gobject-introspection
  ];

  mesonFlags = [
    "-Dcompositor=${phoc}/bin/phoc"
    # Save some time building if tests are disabled
    "-Dtests=${lib.boolToString finalAttrs.finalPackage.doCheck}"
    "-Dc_args=-I${glib.dev}/include/gio-unix-2.0/"
    "-Dsearchd=true"
    "-Dbindings-lib=true"
    "-Dgtk_doc=true"
    "-Dman=true"
  ];

  # Temporarily disabled - Test is broken (SIGABRT)
  doCheck = false;

  nativeCheckInputs = [
    dbus
    xvfb-run
  ];

  checkPhase = ''
    runHook preCheck
    export NO_AT_BRIDGE=1
    xvfb-run -s '-screen 0 800x600x24' dbus-run-session \
      --config-file=${dbus}/share/dbus-1/session.conf \
      meson test --print-errorlogs
    runHook postCheck
  '';

  # Depends on GSettings schemas in gnome-shell
  preFixup = ''
    gappsWrapperArgs+=(
      --prefix XDG_DATA_DIRS : "${glib.getSchemaDataDirPath gnome-shell}"
      --set GNOME_SESSION "${gnome-session}/bin/gnome-session"
    )
  '';

  passthru = {
    providedSessions = [ "phosh" ];
    tests.phosh = nixosTests.phosh;
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Pure Wayland shell for mobile devices";
    homepage = "https://gitlab.gnome.org/World/Phosh/phosh";
    changelog = "https://gitlab.gnome.org/World/Phosh/phosh/-/blob/v${finalAttrs.version}/debian/changelog";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      zhaofengli
      armelclo
    ];

    platforms = lib.platforms.linux;
    mainProgram = "phosh-session";
  };
})
