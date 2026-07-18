{
  lib,
  fetchFromGitHub,
  copyDesktopItems,
  makeDesktopItem,
  python3Packages,
  qt6,
}:
python3Packages.buildPythonApplication (finalAttrs: {
  pname = "labelle";
  version = "1.4.4";

  src = fetchFromGitHub {
    owner = "labelle-org";
    repo = "labelle";
    tag = "v${finalAttrs.version}";
    hash = "sha256-dQHNkotSqCg5LJz9dDOTeIqNgP2D78A6aWFTc9LIFzA=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml --replace-fail "hatch-vcs >=0.3.0,<0.4" "hatch-vcs >=0.3.0"
    substituteInPlace pyproject.toml --replace-fail "Pillow>=8.1.2,<11" "Pillow>=8.1.2"
  '';

  nativeBuildInputs = [
    qt6.wrapQtAppsHook
    python3Packages.hatchling
    python3Packages.hatch-fancy-pypi-readme
    python3Packages.hatch-vcs
    copyDesktopItems
  ];

  buildInputs = [ qt6.qtwayland ];

  propagatedBuildInputs = with python3Packages; [
    darkdetect
    pillow
    platformdirs
    pyqrcode
    pyqt6
    python-barcode
    pyusb
    rich
    typer
  ];

  desktopItems = [
    (makeDesktopItem {
      desktopName = "labelle GUI";
      exec = "labelle-gui";
      name = "labelle GUI";
    })
  ];

  pyproject = true;

  meta = {
    description = "Print labels with LabelManager PnP from Dymo";
    homepage = "https://github.com/labelle-org/labelle";
    changelog = "https://github.com/labelle-org/labelle/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fabianrig ];
    mainProgram = "labelle";
  };
})
