{
  lib,
  stdenv,
  fetchFromGitLab,
  libsForQt5,
  makeDesktopItem,
}:

let
  desktopItem = makeDesktopItem {
    desktopName = "Michabo";
    exec = "Michabo";
    name = "Michabo";
  };

in
stdenv.mkDerivation rec {
  pname = "michabo";
  version = "0.1";

  src = fetchFromGitLab {
    owner = "kaniini";
    repo = "michabo";
    rev = "v${version}";
    sha256 = "0pl4ymdb36r0kwlclfjjp6b1qml3fm9ql7ag5inprny5y8vcjpzn";
    domain = "git.pleroma.social";
  };

  nativeBuildInputs = [
    libsForQt5.qmake
    libsForQt5.wrapQtAppsHook
  ];

  buildInputs = [
    libsForQt5.qtbase
    libsForQt5.qtwebsockets
  ];

  postInstall = ''
    ln -s ${desktopItem}/share $out/share
  '';

  qmakeFlags = [
    "michabo.pro"
    "DESTDIR=${placeholder "out"}/bin"
  ];

  meta = {
    description = "Native desktop app for Pleroma and Mastodon servers";
    homepage = "https://git.pleroma.social/kaniini/michabo";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ fgaz ];
    platforms = lib.platforms.all;
    mainProgram = "Michabo";
  };
}
