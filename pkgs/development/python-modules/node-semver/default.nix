{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "node-semver";
  version = "0.9.1";

  src = fetchFromGitHub {
    owner = "podhmo";
    repo = "python-node-semver";
    tag = version;
    hash = "sha256-akeFBF0za4DjcYfR4/M06D5M19o+4xqfyuG74FPSDBU=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  format = "setuptools";
  pythonImportsCheck = [ "nodesemver" ];

  meta = {
    description = "Port of node-semver";
    homepage = "https://github.com/podhmo/python-semver";
    changelog = "https://github.com/podhmo/python-node-semver/blob/${version}/CHANGES.txt";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
