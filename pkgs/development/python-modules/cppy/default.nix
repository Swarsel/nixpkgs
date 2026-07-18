{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "cppy";
  version = "1.3.1";

  src = fetchFromGitHub {
    owner = "nucleic";
    repo = "cppy";
    tag = version;
    hash = "sha256-/u9JQ2ivjSlBPodfAjeDmJ+HUu1rFZ58p3V5L2dy4Jk=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools-scm ];
  pyproject = true;
  pythonImportsCheck = [ "cppy" ];

  meta = {
    description = "C++ headers for C extension development";
    homepage = "https://github.com/nucleic/cppy";
    changelog = "https://github.com/nucleic/cppy/releases/tag/${src.tag}";
    license = lib.licenses.bsd3;
  };
}
