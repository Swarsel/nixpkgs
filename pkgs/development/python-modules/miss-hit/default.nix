{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  coverage,
  miss-hit-core,
  pytestCheckHook,
  python,
  setuptools,
}:

buildPythonPackage rec {
  pname = "miss-hit";
  version = "0.9.44";

  src = fetchFromGitHub {
    owner = "florianschanda";
    repo = "miss_hit";
    tag = version;
    hash = "sha256-dJZIleDWmdarhmxoKvQxWvI/Tmx9pSCNlgFXj5NFIUc=";
  };

  nativeCheckInputs = [
    coverage
  ];

  checkPhase = ''
    runHook preCheck

    cd tests
    ${python.interpreter} ./run.py

    runHook postCheck
  '';

  build-system = [ setuptools ];

  configurePhase = ''
    runHook preConfigure

    cp setup_agpl.py setup.py

    runHook postConfigure
  '';

  dependencies = [
    miss-hit-core
  ];

  pyproject = true;

  pythonImportsCheck = [
    "miss_hit"
  ];

  meta = {
    description = "Static analysis and other utilities for programs written in the MATLAB/Simulink and Octave languages";
    homepage = "https://misshit.org/";
    changelog = "https://github.com/florianschanda/miss_hit/releases/tag/${version}";
    license = lib.licenses.agpl3Plus;

    maintainers = with lib.maintainers; [
      jacobkoziej
    ];
  };
}
