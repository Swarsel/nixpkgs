{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytest,
  pytest-flakes,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "pytest-quickcheck";
  version = "0.9.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-UFF8ldnaImXU6al4kGjf720mbwXE6Nut9VlvNVrMVoY=";
  };

  propagatedBuildInputs = [ pytest ];

  nativeCheckInputs = [
    pytestCheckHook
    pytest-flakes
  ];

  format = "setuptools";

  meta = {
    description = "Pytest plugin to generate random data inspired by QuickCheck";
    homepage = "https://pypi.org/project/pytest-quickcheck/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ onny ];
  };
}
