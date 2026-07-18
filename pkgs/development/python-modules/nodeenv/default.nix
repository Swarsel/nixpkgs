{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  mock,
  pytestCheckHook,
  python,
  setuptools,
  setuptools-scm,
  which,
}:

buildPythonPackage rec {
  pname = "nodeenv";
  version = "1.10.0";

  src = fetchFromGitHub {
    owner = "ekalinin";
    repo = "nodeenv";
    tag = version;
    hash = "sha256-CosZOTWxXFGrc2ZvPPUwFcUv1blZhyl8MWPnoRCpBBo=";
  };

  nativeCheckInputs = [
    mock
    pytestCheckHook
  ];

  preFixup = ''
    substituteInPlace $out/${python.sitePackages}/nodeenv.py \
      --replace '["which", candidate]' '["${lib.getBin which}/bin/which", candidate]'
  '';

  build-system = [
    setuptools
    setuptools-scm
  ];

  disabledTests = [
    # Test requires coverage
    "test_smoke"
  ];

  pyproject = true;
  pythonImportsCheck = [ "nodeenv" ];

  meta = {
    description = "Node.js virtual environment builder";
    homepage = "https://github.com/ekalinin/nodeenv";
    changelog = "https://github.com/ekalinin/nodeenv/releases/tag/${version}";
    license = lib.licenses.bsd3;
    maintainers = [ ];
    mainProgram = "nodeenv";
  };
}
