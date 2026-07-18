{
  lib,
  fetchFromGitHub,
  python3Packages,
  qt5,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "git-annex-metadata-gui";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "alpernebbi";
    repo = "git-annex-metadata-gui";
    tag = "v${finalAttrs.version}";
    hash = "sha256-VU2d0ls4XOzj2jgqBISdS3FODHoGpBOQZjRhMI+BbA4=";
  };

  nativeBuildInputs = [ qt5.wrapQtAppsHook ];

  preFixup = ''
    makeWrapperArgs+=("''${qtWrapperArgs[@]}")
  '';

  build-system = [
    python3Packages.setuptools
  ];

  dependencies = [
    python3Packages.pyqt5
    python3Packages.git-annex-adapter
  ];

  prePatch = ''
    substituteInPlace setup.py --replace "'PyQt5', " ""
  '';

  pyproject = true;

  meta = {
    description = "Graphical interface for git-annex metadata commands";
    homepage = "https://github.com/alpernebbi/git-annex-metadata-gui";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      dotlambda
      matthiasbeyer
    ];

    platforms = with lib.platforms; linux;
    mainProgram = "git-annex-metadata-gui";
  };
})
