{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  marshmallow,
  pytest-cov-stub,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "marshmallow-polyfield";
  version = "5.11";

  src = fetchFromGitHub {
    owner = "Bachmann1234";
    repo = "marshmallow-polyfield";
    tag = "v${version}";
    hash = "sha256-jbpeyih2Ccw1Rk+QcXRO9AfN5B/DhZmxa/M6FzXHqqs=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov-stub
  ];

  build-system = [ setuptools ];
  dependencies = [ marshmallow ];
  pyproject = true;
  pythonImportsCheck = [ "marshmallow" ];

  meta = {
    description = "Extension to Marshmallow to allow for polymorphic fields";
    homepage = "https://github.com/Bachmann1234/marshmallow-polyfield";
    license = lib.licenses.asl20;
    maintainers = [ ];
    # https://github.com/Bachmann1234/marshmallow-polyfield/issues/45
    broken = true;
  };
}
