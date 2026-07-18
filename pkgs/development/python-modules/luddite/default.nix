{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  packaging,
  pytest-cov-stub,
  pytest-mock,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "luddite";
  version = "1.0.4";

  src = fetchFromGitHub {
    owner = "jumptrading";
    repo = "luddite";
    tag = "v${version}";
    hash = "sha256-iJ3h1XRBzLd4cBKFPNOlIV5Z5XJ/miscfIdkpPIpbJ8=";
  };

  postPatch = ''
    substituteInPlace pytest.ini \
      --replace "--disable-socket" ""
  '';

  nativeBuildInputs = [ setuptools ];
  propagatedBuildInputs = [ packaging ];

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov-stub
    pytest-mock
  ];

  format = "setuptools";
  pythonImportsCheck = [ "luddite" ];

  meta = {
    description = "Checks for out-of-date package versions";
    homepage = "https://github.com/jumptrading/luddite";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ emilytrau ];
    mainProgram = "luddite";
  };
}
