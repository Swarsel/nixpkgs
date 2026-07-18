{
  lib,
  stdenv,
  fetchFromGitHub,
  busybox,
  cmake,
  coreutils,
  dbus,
  gettext,
  graphviz,
  json_c,
  libarchive,
  libusb1,
  libxml2,
  makeWrapper,
  ncurses,
  ninja,
  openssl,
  picocom,
  pkg-config,
  qemu,
  socat,
  sqlite,
  systemd,
  tigervnc,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "nemu";
  version = "3.5.0";

  src = fetchFromGitHub {
    owner = "nemuTUI";
    repo = "nemu";
    rev = "v${finalAttrs.version}";
    hash = "sha256-DGHrCQjaikjkANb+/H69JCIO3S4vgag28BLx1HcCnQ0=";
  };

  postPatch = ''
    substituteInPlace nemu.cfg.sample \
      --replace-fail /usr/bin/vncviewer ${tigervnc}/bin/vncviewer \
      --replace-fail "qemu_bin_path = /usr/bin" "qemu_bin_path = ${qemu}/bin"

    substituteInPlace sh/ntty \
      --replace-fail /usr/bin/socat ${socat}/bin/socat \
      --replace-fail /usr/bin/picocom ${picocom}/bin/picocom \
      --replace-fail start-stop-daemon ${busybox}/bin/start-stop-daemon

    substituteInPlace sh/setup_nemu_nonroot.sh \
      --replace-fail /usr/bin/nemu $out/bin/nemu
  '';

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
    makeWrapper
  ];

  buildInputs = [
    coreutils
    dbus
    gettext
    graphviz
    json_c
    libarchive
    libusb1
    libxml2
    ncurses
    openssl
    picocom
    qemu
    socat
    sqlite
    systemd # for libudev
    tigervnc
  ];

  cmakeFlags = [
    "-DNM_WITH_DBUS=ON"
    "-DNM_WITH_NETWORK_MAP=ON"
    "-DNM_WITH_REMOTE=ON"
    "-DNM_WITH_USB=ON"
  ];

  postInstall = ''
    wrapProgram $out/share/nemu/scripts/upgrade_db.sh \
      --prefix PATH : "${sqlite}/bin"
  '';

  runtimeDependencies = [
    busybox
    picocom
    qemu
    socat
    tigervnc
  ];

  meta = {
    description = "Ncurses UI for QEMU";
    homepage = "https://github.com/nemuTUI/nemu";
    changelog = "https://github.com/nemuTUI/nemu/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ msanft ];
    platforms = lib.platforms.unix;
    mainProgram = "nemu";
  };
})
