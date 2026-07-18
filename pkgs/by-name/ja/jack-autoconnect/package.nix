{
  lib,
  stdenv,
  fetchFromGitHub,
  libjack2,
  libsForQt5,
  pkg-config,
}:
stdenv.mkDerivation {
  pname = "jack_autoconnect";
  # It does not have any versions (yet?)
  version = "unstable-2021-02-01";

  src = fetchFromGitHub {
    owner = "kripton";
    repo = "jack_autoconnect";
    rev = "fe0c8f69149e30979e067646f80b9d326341c02b";
    hash = "sha256-imvNc498Q2W9RKmiOoNepSoJzIv2tGvFG6hx+seiifw=";
  };

  nativeBuildInputs = [
    pkg-config
    libsForQt5.qmake
    libsForQt5.wrapQtAppsHook
  ];

  buildInputs = [
    libsForQt5.qtbase
    libjack2
  ];

  installPhase = ''
    mkdir -p -- "$out/bin"
    cp -- jack_autoconnect "$out/bin"
  '';

  meta = {
    description = "Tiny application that reacts on port registrations by clients and connects them";
    homepage = "https://github.com/kripton/jack_autoconnect";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ unclechu ];
    platforms = lib.platforms.linux;
    mainProgram = "jack_autoconnect";
  };
}
