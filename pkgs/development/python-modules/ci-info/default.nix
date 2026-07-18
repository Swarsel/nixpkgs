{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytest,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "ci-info";
  version = "0.3.0";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-H9UMvUAfKa3/7rGLBIniMtFqwadFisa8MW3qtq5TX7A=";
  };

  doCheck = false; # both tests access network

  nativeCheckInputs = [
    pytest
    pytestCheckHook
  ];

  __structuredAttrs = true;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "ci_info" ];

  meta = {
    description = "Gather continuous integration information on the fly";
    homepage = "https://github.com/mgxd/ci-info";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ bcdarwin ];
  };
})
