{
  lib,
  stdenv,
  fetchFromGitHub,
  fontconfig,
  freetype,
  libGL,
  libnotify,
  libx11,
  libxcb,
  libxkbcommon,
  libxrandr,
  makeDesktopItem,
  nixosTests,
  pkg-config,
  utf8proc,
  wayland,
  xdg-utils,
}:

let
  desktopItem = makeDesktopItem {
    categories = [
      "System"
      "TerminalEmulator"
    ];

    comment = "A simple terminal emulator";
    desktopName = "Wayst";
    exec = "wayst";
    genericName = "Terminal";
    icon = "wayst";

    keywords = [
      "wayst"
      "terminal"
    ];

    name = "wayst";
  };
in
stdenv.mkDerivation {
  pname = "wayst";
  version = "0-unstable-2023-07-16";

  src = fetchFromGitHub {
    owner = "91861";
    repo = "wayst";
    rev = "f8b218eec1af706fd5ae287f5073e6422eb8b6d8";
    hash = "sha256-tA2R6Snk5nqWkPXSbs7wmovWkT97xafdK0e/pKBUIUg=";
  };

  postPatch = ''
    substituteInPlace src/settings.c \
      --replace xdg-open ${xdg-utils}/bin/xdg-open
    substituteInPlace src/main.c \
      --replace notify-send ${libnotify}/bin/notify-send
  '';

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    fontconfig
    libx11
    freetype
    libGL
    libxcb
    libxkbcommon
    libxrandr
    utf8proc
    wayland
  ];

  makeFlags = [ "INSTALL_DIR=\${out}/bin" ];

  preInstall = ''
    mkdir -p $out/bin
  '';

  postInstall = ''
    mkdir -p $out/share/applications
    ln -s ${desktopItem}/share/applications/* $out/share/applications
    install -D icons/wayst.svg $out/share/icons/hicolor/scalable/apps/wayst.svg
  '';

  enableParallelBuilding = true;
  passthru.tests.test = nixosTests.terminal-emulators.wayst;

  meta = {
    description = "Simple terminal emulator";
    homepage = "https://github.com/91861/wayst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ berbiche ];
    platforms = lib.platforms.linux;
    mainProgram = "wayst";
  };
}
