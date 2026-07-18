{
  lib,
  fetchFromGitHub,
  python3Packages,
  qt6,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "cfclient";
  version = "2025.12.1";

  src = fetchFromGitHub {
    owner = "bitcraze";
    repo = "crazyflie-clients-python";
    tag = finalAttrs.version;
    hash = "sha256-+3RZRShELL2iXxz95eRhK5UPp5NZ1yJO4NDlZ7cDTjI=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    qt6.qtbase
  ];

  # No tests
  doCheck = false;

  # Use wrapQtApp for Python scripts as the manual mentions that wrapQtAppsHook only applies to binaries
  postFixup = ''
    wrapQtApp "$out/bin/cfclient" \
      --set QT_QPA_PLATFORM "wayland" \
      --set XDG_CURRENT_DESKTOP "Wayland" \
      ''${qtWrapperArgs[@]}
  '';

  build-system = with python3Packages; [
    setuptools
    setuptools-scm
  ];

  dependencies = with python3Packages; [
    appdirs
    cflib
    numpy
    pyopengl
    pyserial
    pysdl2
    pyqtgraph
    pyqt6
    pyqt6-sip
    pyyaml
    pyzmq
    scipy
    setuptools
    vispy
  ];

  dontWrapQtApps = true;
  pyproject = true;

  pythonRelaxDeps = [
    "numpy"
    "pyqt6"
    "pyzmq"
    "vispy"
  ];

  meta = {
    description = "Host applications and library for Crazyflie drones written in Python";
    homepage = "https://github.com/bitcraze/crazyflie-clients-python";
    changelog = "https://github.com/bitcraze/crazyflie-clients-python/releases/tag/${finalAttrs.version}";
    license = lib.licenses.gpl2Only;
    maintainers = [ lib.maintainers.brianmcgillion ];
    platforms = lib.platforms.linux;
  };
})
