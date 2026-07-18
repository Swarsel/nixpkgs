{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "wyoming-openwakeword";
  version = "2.1.0";

  src = fetchFromGitHub {
    owner = "rhasspy";
    repo = "wyoming-openwakeword";
    tag = "v${finalAttrs.version}";
    hash = "sha256-yYDZ1wOhCTdYGeRmtbOgx5/zkF0Baxmha7eO/i0p49g=";
  };

  build-system = with python3Packages; [
    setuptools
  ];

  dependencies = with python3Packages; [
    pyopen-wakeword
    wyoming
  ];

  pyproject = true;

  pythonImportsCheck = [
    "wyoming_openwakeword"
  ];

  pythonRelaxDeps = [
    "wyoming"
  ];

  meta = {
    description = "Open source voice assistant toolkit for many human languages";
    homepage = "https://github.com/rhasspy/wyoming-openwakeword";
    changelog = "https://github.com/rhasspy/wyoming-openwakeword/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hexa ];
    mainProgram = "wyoming-openwakeword";
  };
})
