{
  lib,
  stdenv,
  fetchFromGitHub,
  autoconf-archive,
  autoreconfHook,
  gettext,
  libnl,
  ncurses,
  nix-update-script,
  pciutils,
  pkg-config,
  powertop,
  testers,
  xset,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "powertop";
  version = "2.15";

  src = fetchFromGitHub {
    owner = "fenrus75";
    repo = "powertop";
    tag = "v${finalAttrs.version}";
    hash = "sha256-53jfqt0dtMqMj3W3m6ravUTzApLQcljDHfdXejeZa4M=";
  };

  outputs = [
    "out"
    "man"
  ];

  postPatch = ''
    substituteInPlace src/main.cpp --replace-fail "/sbin/modprobe" "modprobe"
    substituteInPlace src/calibrate/calibrate.cpp --replace-fail "/usr/bin/xset" "${lib.getExe xset}"
    substituteInPlace src/tuning/bluetooth.cpp --replace-fail "/usr/bin/hcitool" "hcitool"
  '';

  nativeBuildInputs = [
    autoconf-archive
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    gettext
    libnl
    ncurses
    pciutils
    zlib
  ];

  passthru = {
    tests.version = testers.testVersion {
      inherit (finalAttrs) version;
      command = "powertop --version";
      package = powertop;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    inherit (finalAttrs.src.meta) homepage;
    description = "Analyze power consumption on Intel-based laptops";
    changelog = "https://github.com/fenrus75/powertop/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl2Only;

    maintainers = with lib.maintainers; [
      fpletz
      anthonyroussel
    ];

    platforms = lib.platforms.linux;
    mainProgram = "powertop";
  };
})
