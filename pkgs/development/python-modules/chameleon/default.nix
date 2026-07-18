{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "chameleon";
  version = "4.6.0";

  src = fetchFromGitHub {
    owner = "malthe";
    repo = "chameleon";
    tag = version;
    hash = "sha256-zCEM5yl8Y11FbexD7veS9bFJgm30L6fsTde59m2t1ec=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "chameleon" ];

  meta = {
    description = "Fast HTML/XML Template Compiler";
    homepage = "https://chameleon.readthedocs.io";
    changelog = "https://github.com/malthe/chameleon/blob/${src.tag}/CHANGES.rst";
    license = lib.licenses.bsd0;
    maintainers = [ ];
    downloadPage = "https://github.com/malthe/chameleon";
  };
}
