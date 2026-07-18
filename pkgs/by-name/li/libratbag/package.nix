{
  lib,
  stdenv,
  fetchFromGitHub,
  check,
  gitMinimal,
  glib,
  gobject-introspection,
  json-glib,
  libevdev,
  libunistring,
  meson,
  ninja,
  pkg-config,
  python3,
  swig,
  systemd,
  udev,
  valgrind,
  wrapGAppsNoGuiHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libratbag";
  version = "0.18";

  src = fetchFromGitHub {
    owner = "libratbag";
    repo = "libratbag";
    rev = "v${finalAttrs.version}";
    hash = "sha256-dAWKDF5hegvKhUZ4JW2J/P9uSs4xNrZLNinhAff6NSc=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    gitMinimal
    swig
    check
    valgrind
    wrapGAppsNoGuiHook
    gobject-introspection
  ];

  buildInputs = [
    glib
    systemd
    udev
    libevdev
    json-glib
    libunistring
    (python3.withPackages (
      ps: with ps; [
        evdev
        pygobject3
      ]
    ))
  ];

  mesonFlags = [
    "-Dsystemd-unit-dir=./lib/systemd/system/"
  ];

  meta = {
    description = "Configuration library for gaming mice";
    homepage = "https://github.com/libratbag/libratbag";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ mvnetbiz ];
    platforms = lib.platforms.linux;
  };
})
