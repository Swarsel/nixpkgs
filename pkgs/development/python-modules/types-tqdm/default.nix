{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
  types-requests,
}:

buildPythonPackage (finalAttrs: {
  pname = "types-tqdm";
  version = "4.68.0.20260608";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-4d/d+HcPvDDsr5WuV8KGOXgxI1BkMI99/CsdZoSnYQc=";
    pname = "types_tqdm";
  };

  # This package does not have tests.
  doCheck = false;
  __structuredAttrs = true;
  build-system = [ setuptools ];
  dependencies = [ types-requests ];
  pyproject = true;

  meta = {
    description = "Typing stubs for tqdm";
    homepage = "https://pypi.org/project/types-tqdm/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
})
