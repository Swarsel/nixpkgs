{
  lib,
  stdenv,
  fetchFromGitHub,
  gitUpdater,
  libsForQt5,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cmst";
  version = "2023.03.14";

  src = fetchFromGitHub {
    owner = "andrew-bibb";
    repo = "cmst";
    tag = "${finalAttrs.pname}-${finalAttrs.version}";
    hash = "sha256-yTqPxywPbtxTy1PPG+Mq64u8MrB27fEdmt1B0pn0BVk=";
  };

  postPatch = ''
    for f in $(find . -name \*.cpp -o -name \*.pri -o -name \*.pro); do
      substituteInPlace $f --replace /etc $out/etc --replace /usr $out
    done
  '';

  nativeBuildInputs = [
    libsForQt5.qmake
    libsForQt5.qttools
    libsForQt5.wrapQtAppsHook
  ];

  buildInputs = [ libsForQt5.qtbase ];

  passthru.updateScript = gitUpdater {
    rev-prefix = "${finalAttrs.pname}-";
  };

  meta = {
    description = "QT GUI for Connman with system tray icon";
    homepage = "https://github.com/andrew-bibb/cmst";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      matejc
      romildo
    ];

    platforms = lib.platforms.linux;
    mainProgram = "cmst";
  };
})
