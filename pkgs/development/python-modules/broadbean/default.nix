{
  lib,
  buildPythonPackage,
  fetchPypi,
  hypothesis,
  matplotlib,
  numpy,
  pytestCheckHook,
  schema,
  setuptools,
  versioningit,
  wheel,
}:

buildPythonPackage rec {
  pname = "broadbean";
  version = "0.14.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-v+Ov6mlSnaJG98ooA9AhPGJflrFafKQoO5wi+PxcZVw=";
  };

  nativeBuildInputs = [
    setuptools
    versioningit
    wheel
  ];

  propagatedBuildInputs = [
    numpy
    matplotlib
    schema
  ];

  nativeCheckInputs = [
    hypothesis
    pytestCheckHook
  ];

  disabledTests = [
    # on a 200ms deadline
    "test_points"
  ];

  pyproject = true;
  pythonImportsCheck = [ "broadbean" ];

  meta = {
    description = "Library for making pulses that can be leveraged with QCoDeS";
    homepage = "https://qcodes.github.io/broadbean";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ evilmav ];
  };
}
