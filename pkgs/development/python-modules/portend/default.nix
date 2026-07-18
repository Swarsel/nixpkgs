{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytestCheckHook,
  setuptools-scm,
  tempora,
}:

buildPythonPackage (finalAttrs: {
  pname = "portend";
  version = "3.2.1";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-qp1Aqx+eFL231AH0IhDfNdAXybl5kbrrGFaM7fuMZIk=";
  };

  postPatch = ''
    sed -i "/coherent\.licensed/d" pyproject.toml;
  '';

  nativeCheckInputs = [ pytestCheckHook ];
  # Some of the tests use localhost networking.
  __darwinAllowLocalNetworking = true;
  build-system = [ setuptools-scm ];
  dependencies = [ tempora ];
  pyproject = true;
  pythonImportsCheck = [ "portend" ];

  meta = {
    description = "Monitor TCP ports for bound or unbound states";
    homepage = "https://github.com/jaraco/portend";
    license = lib.licenses.bsd3;
  };
})
