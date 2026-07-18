{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hypothesis,
  outcome,
  pytest,
  setuptools,
  trio,
}:

buildPythonPackage rec {
  pname = "pytest-trio";
  version = "0.8.0";

  src = fetchFromGitHub {
    owner = "python-trio";
    repo = "pytest-trio";
    tag = "v${version}";
    hash = "sha256-gUH35Yk/pBD2EdCEt8D0XQKWU8BwmX5xtAW10qRhoYk=";
  };

  buildInputs = [ pytest ];
  # broken with pytest 5 and 6
  doCheck = false;

  nativeCheckInputs = [
    pytest
    hypothesis
  ];

  checkPhase = ''
    rm pytest.ini
    PYTHONPATH=$PWD:$PYTHONPATH pytest
  '';

  build-system = [ setuptools ];

  dependencies = [
    trio
    outcome
  ];

  pyproject = true;
  pythonImportsCheck = [ "pytest_trio" ];

  meta = {
    description = "Pytest plugin for trio";
    homepage = "https://github.com/python-trio/pytest-trio";

    license = with lib.licenses; [
      asl20
      mit
    ];

    maintainers = with lib.maintainers; [ hexa ];
  };
}
