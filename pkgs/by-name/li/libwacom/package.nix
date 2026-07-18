{
  lib,
  stdenv,
  fetchFromGitHub,
  glib,
  libevdev,
  libgudev,
  libwacom-surface,
  meson,
  ninja,
  pkg-config,
  python3,
  udev,
  udevCheckHook,
  valgrind,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libwacom";
  version = "2.19.0";

  src = fetchFromGitHub {
    owner = "linuxwacom";
    repo = "libwacom";
    rev = "libwacom-${finalAttrs.version}";
    hash = "sha256-0TlTt/9kN8NiWGDhvzMfvgJZnlzwcEFzAOCSzRowX8A=";
  };

  outputs = [
    "bin"
    "out"
    "dev"
  ];

  postPatch = ''
    patchShebangs test/check-files-in-git.sh
  '';

  nativeBuildInputs = [
    pkg-config
    meson
    ninja
    python3
    udevCheckHook
  ];

  buildInputs = [
    glib
    udev
    libevdev
    libgudev
    (python3.withPackages (pp: [
      pp.libevdev
      pp.pyudev
    ]))
  ];

  mesonFlags = [
    (lib.mesonEnable "tests" finalAttrs.finalPackage.doCheck)
    (lib.mesonOption "sysconfdir" "/etc")
  ];

  # Tests are in the `tests` pass-through derivation because one of them is flaky, frequently causing build failures.
  # See https://github.com/NixOS/nixpkgs/issues/328140
  doCheck = false;

  nativeCheckInputs = [
    valgrind
    (python3.withPackages (ps: [
      ps.libevdev
      ps.pytest
      ps.pyudev
    ]))
  ];

  doInstallCheck = true;

  passthru.tests = {
    inherit libwacom-surface;
    tests = finalAttrs.finalPackage.overrideAttrs { doCheck = true; };
  };

  meta = {
    description = "Libraries, configuration, and diagnostic tools for Wacom tablets running under Linux";
    homepage = "https://linuxwacom.github.io/";
    changelog = "https://github.com/linuxwacom/libwacom/blob/${finalAttrs.src.rev}/NEWS";
    license = lib.licenses.hpnd;
    platforms = lib.platforms.linux;

    badPlatforms = [
      # Mandatory shared library.
      lib.systems.inspect.platformPatterns.isStatic
    ];

    teams = [ lib.teams.freedesktop ];
  };
})
