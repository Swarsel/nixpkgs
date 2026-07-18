{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "voluptuous";
  version = "0.16.0";

  src = fetchFromGitHub {
    owner = "alecthomas";
    repo = "voluptuous";
    tag = version;
    hash = "sha256-Lph+vNsMm69Oqqk3mX27+BR1PsZNxqiI5Uu8nY8hCBc=";
  };

  nativeBuildInputs = [ setuptools ];
  nativeCheckInputs = [ pytestCheckHook ];
  enabledTestPaths = [ "voluptuous/tests/" ];
  pyproject = true;
  pythonImportsCheck = [ "voluptuous" ];

  meta = {
    description = "Python data validation library";
    homepage = "http://alecthomas.github.io/voluptuous/";
    changelog = "https://github.com/alecthomas/voluptuous/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ fab ];
    downloadPage = "https://github.com/alecthomas/voluptuous";
  };
}
