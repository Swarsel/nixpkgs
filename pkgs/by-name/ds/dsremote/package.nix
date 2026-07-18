{
  lib,
  stdenv,
  fetchFromGitLab,
  qt5,
}:
stdenv.mkDerivation {
  pname = "dsremote";
  version = "0-unstable-2025-07-07";

  src = fetchFromGitLab {
    owner = "Teuniz";
    repo = "DSRemote";
    rev = "b290debcfecd4fecf2069fb958bd43fe9e5ce5e1";
    hash = "sha256-7a13T8MwIFDhrXe7xqB84D6MwfTYs1gJj6VWs4JbzEM=";
  };

  postPatch = ''
    substituteInPlace dsremote.pro \
      --replace-fail "/usr/" "$out/" \
      --replace-fail "/etc/" "$out/etc/"
  '';

  nativeBuildInputs = [
    qt5.qmake
    qt5.wrapQtAppsHook
    qt5.qtbase
  ];

  hardeningDisable = [ "fortify" ];

  meta = {
    description = "Rigol DS1000Z remote control and waveform viewer";
    homepage = "https://www.teuniz.net/DSRemote";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ mksafavi ];
    platforms = lib.platforms.linux;
    mainProgram = "dsremote";
  };
}
