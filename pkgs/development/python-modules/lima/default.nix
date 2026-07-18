{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "lima";
  version = "0.5";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-OxBBmzZGM+PtpSw5ixIMVH/Z1YVOTO/ZvPecPAoAEmM=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "lima" ];

  meta = {
    description = "Lightweight Marshalling of Python Objects";
    homepage = "https://github.com/b6d/lima";
    changelog = "https://github.com/b6d/lima/blob/${version}/CHANGELOG.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ zhaofengli ];
  };
}
