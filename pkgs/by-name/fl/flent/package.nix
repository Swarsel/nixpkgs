{
  lib,
  fetchPypi,
  iputils,
  irtt,
  netperf,
  nix-update-script,
  procps,
  python3Packages,
  qt6,
}:
python3Packages.buildPythonApplication (finalAttrs: {
  pname = "flent";
  version = "2.3.0";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-qy+BvMpBDBtBqEEM9yEko/Gb2pusxF/LqiutSKlS2eE=";
  };

  nativeBuildInputs = [ qt6.wrapQtAppsHook ];
  buildInputs = [ qt6.qtbase ];
  nativeCheckInputs = [ python3Packages.unittestCheckHook ];

  preCheck = ''
    # we want the gui tests to always run
    sed -i 's|self.skip|pass; #&|' unittests/test_gui.py

    # Dummy qt setup for gui tests
    export QT_PLUGIN_PATH="${qt6.qtbase}/${qt6.qtbase.qtPluginPrefix}"
    export QT_QPA_PLATFORM=offscreen
  '';

  build-system = with python3Packages; [
    setuptools
    sphinx
  ];

  dependencies = with python3Packages; [
    matplotlib
    pyqt6
    qtpy
  ];

  makeWrapperArgs = [
    "--prefix"
    "PATH"
    ":"
    (lib.makeBinPath [
      iputils
      irtt
      netperf
      procps
    ])
  ];

  pyproject = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "FLExible Network Tester";
    homepage = "https://flent.org";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ mmlb ];
    badPlatforms = lib.platforms.darwin;
    mainProgram = "flent";
  };
})
