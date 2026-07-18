{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  lark,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "python-hcl2";
  version = "7.3.1";

  src = fetchFromGitHub {
    owner = "amplify-education";
    repo = "python-hcl2";
    tag = "v${version}";
    hash = "sha256-aHaDZvgpiINUEdSYlUVwa0l80mujb9F04eboAdiuzDc=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [ lark ];
  pyproject = true;
  pythonImportsCheck = [ "hcl2" ];

  meta = {
    description = "Parser for HCL2 written in Python using Lark";
    homepage = "https://github.com/amplify-education/python-hcl2";
    changelog = "https://github.com/amplify-education/python-hcl2/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ shivaraj-bh ];
  };
}
