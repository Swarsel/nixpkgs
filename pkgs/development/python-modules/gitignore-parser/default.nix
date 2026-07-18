{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
  unittestCheckHook,
}:

buildPythonPackage rec {
  pname = "gitignore-parser";
  version = "0.1.13";

  src = fetchFromGitHub {
    owner = "mherrmann";
    repo = "gitignore_parser";
    tag = "v${version}";
    hash = "sha256-jd5C8whfdLuEC+ebDAAYso33o2H963P+8RWcm26koVM=";
  };

  nativeCheckInputs = [ unittestCheckHook ];
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "gitignore_parser" ];

  meta = {
    description = "Spec-compliant gitignore parser";
    homepage = "https://github.com/mherrmann/gitignore_parser";
    changelog = "https://github.com/mherrmann/gitignore_parser/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
