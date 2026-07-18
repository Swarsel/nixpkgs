{
  lib,
  fetchFromGitHub,
  fetchpatch,
  python3Packages,
  qt5,
}:
python3Packages.buildPythonApplication (finalAttrs: {
  pname = "labelImg";
  version = "1.8.6";

  src = fetchFromGitHub {
    owner = "HumanSignal";
    repo = "labelImg";
    tag = "v${finalAttrs.version}";
    hash = "sha256-RJxCtiDOePajlrjy9cpKETSKsWlH/Dlu1iFMj2aO4XU=";
  };

  patches = [
    # fixes https://github.com/heartexlabs/labelImg/issues/838
    # can be removed after next upstream version bump
    (fetchpatch {
      hash = "sha256-BmbnJS95RBfoNQT0E6JDJ/IZfBa+tv1C69+RVOSFdRA=";
      url = "https://github.com/heartexlabs/labelImg/commit/5c38b6bcddce895d646e944e3cddcb5b43bf8b8b.patch";
    })
  ];

  nativeBuildInputs = [
    qt5.wrapQtAppsHook
  ];

  preBuild = ''
    make qt5py3
  '';

  postInstall = ''
    install -Dm644 libs/resources.py $out/${python3Packages.python.sitePackages}/libs
  '';

  preFixup = ''
    makeWrapperArgs+=("''${qtWrapperArgs[@]}")
  '';

  build-system = with python3Packages; [
    setuptools
    pyqt5
  ];

  dependencies = with python3Packages; [
    distutils
    pyqt5
    lxml
  ];

  dontWrapQtApps = true;
  pyproject = true;
  pythonImportsCheck = [ "labelImg" ];

  meta = {
    description = "Graphical image annotation tool and label object bounding boxes in images";
    homepage = "https://github.com/HumanSignal/labelImg";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.cmcdragonkai ];
    platforms = lib.platforms.linux;
    mainProgram = "labelImg";
  };
})
