{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "simanneal";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "perrygeo";
    repo = "simanneal";
    tag = finalAttrs.version;
    hash = "sha256-yKZHkrf6fM0WsHczIEK5Kxusz5dSBgydK3fLu1nDyvk=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  __structuredAttrs = true;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "simanneal" ];

  meta = {
    description = "Python implementation of the simulated annealing optimization technique";
    homepage = "https://github.com/perrygeo/simanneal";
    license = lib.licenses.isc;
    maintainers = with lib.maintainers; [ veprbl ];
  };
})
