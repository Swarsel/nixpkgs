{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "puremagic";
  version = "1.30";

  src = fetchFromGitHub {
    owner = "cdgriffith";
    repo = "puremagic";
    tag = version;
    hash = "sha256-k2xrcML8XxI9cMTQTv0pDLkOrmEr5mbDnVsyWuD1rEc=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "puremagic" ];

  meta = {
    description = "Implementation of magic file detection";
    homepage = "https://github.com/cdgriffith/puremagic";
    changelog = "https://github.com/cdgriffith/puremagic/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
