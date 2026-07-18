{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  pytestCheckHook,
  sure,
}:

buildPythonPackage rec {
  pname = "py-partiql-parser";
  version = "0.6.3";

  src = fetchFromGitHub {
    owner = "getmoto";
    repo = "py-partiql-parser";
    tag = version;
    hash = "sha256-99GkYfsscifVAws+Rgn1Tb2FZxY/4OtNvOoXGGmzbco=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    sure
  ];

  build-system = [ hatchling ];
  pyproject = true;
  pythonImportsCheck = [ "py_partiql_parser" ];

  meta = {
    description = "Tokenizer/parser/executor for the PartiQL-language";
    homepage = "https://github.com/getmoto/py-partiql-parser";
    changelog = "https://github.com/getmoto/py-partiql-parser/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ centromere ];
  };
}
