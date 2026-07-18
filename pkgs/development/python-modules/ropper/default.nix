{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  capstone,
  filebytes,
  keystone-engine,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "ropper";
  version = "1.13.13";

  src = fetchFromGitHub {
    owner = "sashs";
    repo = "Ropper";
    tag = "v${version}";
    hash = "sha256-MOAbACLDdeKCMV4K/n1rAQlxDN0JoDIiUF6Zr3yPw8o=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    capstone
    filebytes
  ];

  optional-dependencies = {
    ropchain = [ keystone-engine ];
  };

  pyproject = true;
  pythonImportsCheck = [ "ropper" ];

  meta = {
    description = "Show information about files in different file formats";
    homepage = "https://scoding.de/ropper/";
    changelog = "https://github.com/sashs/Ropper/releases/tag/${src.tag}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ bennofs ];
    mainProgram = "ropper";
  };
}
