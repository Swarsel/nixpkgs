{
  lib,
  stdenv,
  fetchurl,
  atk,
  cairo,
  colord,
  desktop-file-utils,
  docutils,
  egl-wayland,
  fribidi,
  gettext,
  gi-docgen,
  glib,
  gnome-desktop,
  gnome-settings-daemon,
  gobject-introspection,
  graphene,
  gsettings-desktop-schemas,
  gtk4,
  harfbuzz,
  lcms2,
  libGL,
  libadwaita,
  libcanberra,
  libdisplay-info,
  libdrm,
  libei,
  libgbm,
  libgudev,
  libice,
  libinput,
  libsm,
  libstartup_notification,
  libsysprof-capture,
  libwacom,
  libx11,
  libxau,
  libxcb,
  libxcomposite,
  libxcursor,
  libxcvt,
  libxdamage,
  libxext,
  libxfixes,
  libxi,
  libxinerama,
  libxkbcommon,
  libxkbfile,
  libxrandr,
  libxtst,
  mesa-gl-headers,
  meson,
  ninja,
  pango,
  pipewire,
  pkg-config,
  python3,
  runCommand,
  sysprof,
  udevCheckHook,
  wayland,
  wayland-protocols,
  wayland-scanner,
  wrapGAppsHook4,
  xkeyboard_config,
  xorg-server,
  xvfb-run,
  xwayland,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mutter";
  version = "48.7";

  src = fetchurl {
    url = "mirror://gnome/sources/mutter/${lib.versions.major finalAttrs.version}/mutter-${finalAttrs.version}.tar.xz";
    hash = "sha256-7BAqo8uw45ABIGYnrKMFUxRVX3BgneXmwrfvzR+pDyA=";
  };

  outputs = [
    "out"
    "dev"
    "man"
    "devdoc"
  ];

  postPatch = ''
    patchShebangs src/backends/native/gen-default-modes.py

    # https://gitlab.gnome.org/GNOME/mutter/-/merge_requests/3981
    substituteInPlace src/frames/main.c \
      --replace-fail "libadwaita-1.so.0" "${libadwaita}/lib/libadwaita-1.so.0"
  '';

  strictDeps = true;

  nativeBuildInputs = [
    desktop-file-utils
    docutils # for rst2man
    gettext
    glib
    libxcvt
    meson
    ninja
    xvfb-run
    pkg-config
    python3
    python3.pkgs.argcomplete # for register-python-argcomplete
    wayland-scanner
    wrapGAppsHook4
    gi-docgen
    xorg-server
    gobject-introspection
    udevCheckHook
  ];

  buildInputs = [
    cairo
    egl-wayland
    glib
    gnome-desktop
    gnome-settings-daemon
    gsettings-desktop-schemas
    atk
    fribidi
    harfbuzz
    libcanberra
    libdrm
    libgbm
    libei
    libdisplay-info
    libGL
    libgudev
    libinput
    libstartup_notification
    libwacom
    libsm
    colord
    lcms2
    pango
    pipewire
    sysprof # for D-Bus interfaces
    libsysprof-capture
    xwayland
    wayland
    wayland-protocols
    # X11 client
    gtk4
    libice
    libx11
    libxcomposite
    libxcursor
    libxdamage
    libxext
    libxfixes
    libxi
    libxtst
    libxkbfile
    xkeyboard_config
    libxkbcommon
    libxcb
    libxrandr
    libxinerama
    libxau

    # for gdctl shebang
    (python3.withPackages (pp: [
      pp.pygobject3
      pp.argcomplete
    ]))
  ];

  propagatedBuildInputs = [
    # required for pkg-config to detect mutter-mtk
    graphene
    mesa-gl-headers
  ];

  mesonFlags = [
    "-Degl_device=true"
    "-Dinstalled_tests=false" # TODO: enable these
    "-Dtests=disabled"
    # For NVIDIA proprietary driver up to 470.
    # https://src.fedoraproject.org/rpms/mutter/pull-request/49
    "-Dwayland_eglstream=true"
    "-Dprofiler=true"
    "-Dxwayland_path=${lib.getExe xwayland}"
    # This should be auto detected, but it looks like it manages a false
    # positive.
    "-Dxwayland_initfd=disabled"
    "-Ddocs=true"
  ];

  # Install udev files into our own tree.
  env.PKG_CONFIG_UDEV_UDEVDIR = "${placeholder "out"}/lib/udev";
  doInstallCheck = true;

  postFixup = ''
    # Cannot be in postInstall, otherwise _multioutDocs hook in preFixup will move right back.
    # TODO: Move this into a directory devhelp can find.
    moveToOutput "share/mutter-${finalAttrs.passthru.libmutter_api_version}/doc" "$devdoc"
  '';

  separateDebugInfo = true;

  passthru = {
    libdir = "${finalAttrs.finalPackage}/lib/mutter-${finalAttrs.passthru.libmutter_api_version}";
    libmutter_api_version = "16"; # bumped each dev cycle

    tests = {
      libdirExists = runCommand "mutter-libdir-exists" { } ''
        if [[ ! -d ${finalAttrs.finalPackage.libdir} ]]; then
          echo "passthru.libdir should contain a directory, “${finalAttrs.finalPackage.libdir}” is not one."
          exit 1
        fi
        touch $out
      '';
    };
  };

  meta = {
    description = "Window manager for GNOME";
    homepage = "https://gitlab.gnome.org/GNOME/mutter";
    changelog = "https://gitlab.gnome.org/GNOME/mutter/-/blob/${finalAttrs.version}/NEWS?ref_type=tags";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
    mainProgram = "mutter";
    teams = [ lib.teams.pantheon ];
  };
})
