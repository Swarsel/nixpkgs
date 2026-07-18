{
  lib,
  stdenv,
  fetchFromGitLab,
  cairo,
  check,
  doxygen,
  epoll-shim,
  gitUpdater,
  glib,
  graphviz,
  gtk3,
  libevdev,
  libudev-devd,
  libwacom,
  lua5_4,
  meson,
  mtdev,
  ninja,
  nixosTests,
  pkg-config,
  python3,
  runCommand,
  udev,
  udevCheckHook,
  valgrind,
  wayland-scanner,
  documentationSupport ? false,
  eventGUISupport ? false,
  luaSupport ? true,
  testsSupport ? false,
  wacomSupport ? stdenv.hostPlatform.isLinux,
}:

let
  sphinx-build =
    let
      env = python3.withPackages (
        pp: with pp; [
          sphinx
          recommonmark
          sphinx-rtd-theme
        ]
      );
    in
    # Expose only the sphinx-build binary to avoid contaminating
    # everything with Sphinx’s Python environment.
    runCommand "sphinx-build" { } ''
      mkdir -p "$out/bin"
      ln -s "${env}/bin/sphinx-build" "$out/bin"
    '';
in

stdenv.mkDerivation rec {
  pname = "libinput";
  version = "1.31.3";

  src = fetchFromGitLab {
    owner = "libinput";
    repo = "libinput";
    rev = version;
    hash = "sha256-2l+YGD1AFTwJRouMg0d3nQX+2me6A4yOB4g2WE2H//g=";
    domain = "gitlab.freedesktop.org";
  };

  outputs = [
    "bin"
    "out"
    "dev"
  ];

  postPatch = ''
    patchShebangs \
      test/symbols-leak-test \
      test/check-leftover-udev-rules.sh \
      test/helper-copy-and-exec-from-tmp.sh

    # Don't create an empty directory under /etc.
    sed -i "/install_emptydir(dir_etc \/ 'libinput')/d" meson.build
  '';

  nativeBuildInputs = [
    pkg-config
    meson
    ninja
    udevCheckHook
  ]
  ++ lib.optionals documentationSupport [
    doxygen
    graphviz
    sphinx-build
  ];

  buildInputs = [
    libevdev
    mtdev
    (python3.withPackages (
      pp: with pp; [
        pp.libevdev # already in scope
        pyudev
        pyyaml
        setuptools
      ]
    ))
  ]
  ++ lib.optionals stdenv.hostPlatform.isFreeBSD [
    epoll-shim
  ]
  ++ lib.optionals wacomSupport [
    libwacom
  ]
  ++ lib.optionals luaSupport [
    lua5_4
  ]
  ++ lib.optionals eventGUISupport [
    # GUI event viewer
    cairo
    glib
    gtk3
    wayland-scanner
  ];

  propagatedBuildInputs =
    lib.optional stdenv.hostPlatform.isLinux udev
    ++ lib.optional stdenv.hostPlatform.isFreeBSD libudev-devd;

  mesonFlags = [
    (lib.mesonBool "documentation" documentationSupport)
    (lib.mesonBool "debug-gui" eventGUISupport)
    (lib.mesonBool "tests" testsSupport)
    (lib.mesonBool "libwacom" wacomSupport)
    (lib.mesonEnable "lua-plugins" luaSupport)
    "--sysconfdir=/etc"
    "--libexecdir=${placeholder "bin"}/libexec"
  ]
  ++ lib.optionals stdenv.hostPlatform.isBSD [
    "-Depoll-dir=${epoll-shim}"
  ];

  doCheck = testsSupport && stdenv.hostPlatform == stdenv.buildPlatform;

  nativeCheckInputs = [
    check
    valgrind
  ];

  doInstallCheck = true;

  passthru = {
    tests = {
      libinput-module = nixosTests.libinput;
    };

    updateScript = gitUpdater {
      patchlevel-unstable = true;
    };
  };

  meta = {
    description = "Handles input devices in Wayland compositors and provides a generic X.Org input driver";
    homepage = "https://www.freedesktop.org/wiki/Software/libinput/";
    changelog = "https://gitlab.freedesktop.org/libinput/libinput/-/releases/${version}";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.linux ++ lib.platforms.freebsd;

    badPlatforms = [
      # Mandatory shared library.
      lib.systems.inspect.platformPatterns.isStatic
    ];

    mainProgram = "libinput";
    teams = [ lib.teams.freedesktop ];
  };
}
