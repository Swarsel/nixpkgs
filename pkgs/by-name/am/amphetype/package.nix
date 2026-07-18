{
  lib,
  fetchFromGitLab,
  copyDesktopItems,
  makeDesktopItem,
  python3Packages,
  qt5,
}:

let
  pname = "amphetype";
  version = "1.0.0";
  description = "Advanced typing practice program";
in
python3Packages.buildPythonApplication {
  inherit pname version;

  src = fetchFromGitLab {
    owner = "franksh";
    repo = "amphetype";
    tag = "v${version}";
    hash = "sha256-pve2f+XMfFokMCtW3KdeOJ9Ey330Gwv/dk1+WBtrBEQ=";
  };

  nativeBuildInputs = [
    copyDesktopItems
    qt5.wrapQtAppsHook
  ];

  buildInputs = [
    qt5.qtwayland
  ];

  # no tests
  doCheck = false;

  build-system = with python3Packages; [
    setuptools
  ];

  dependencies = with python3Packages; [
    editdistance
    pyqt5
    translitcodec
  ];

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "Education"
        "Qt"
      ];

      comment = description;
      desktopName = "Amphetype";
      exec = "amphetype";
      genericName = "Typing Practice";
      name = "amphetype";
    })
  ];

  makeWrapperArgs = [
    "\${qtWrapperArgs[@]}"
  ];

  pyproject = true;

  meta = {
    inherit description;
    homepage = "https://gitlab.com/franksh/amphetype";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ rycee ];
    mainProgram = "amphetype";
  };
}
