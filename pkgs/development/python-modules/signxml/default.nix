{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  certifi,
  cryptography,
  hatch-vcs,
  hatchling,
  lxml,
  pyopenssl,
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "signxml";
  version = "4.5.1";

  src = fetchFromGitHub {
    owner = "XML-Security";
    repo = "signxml";
    tag = "v${finalAttrs.version}";
    hash = "sha256-0DzHw7E2sAJE3O7io++zjsi07FbkBD24EjGDOVo8/9s=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    hatchling
    hatch-vcs
  ];

  dependencies = [
    certifi
    cryptography
    lxml
    pyopenssl
  ];

  enabledTestPaths = [ "test/test.py" ];
  pyproject = true;
  pythonImportsCheck = [ "signxml" ];

  meta = {
    description = "Python XML Signature and XAdES library";
    homepage = "https://github.com/XML-Security/signxml";
    changelog = "https://github.com/XML-Security/signxml/blob/${finalAttrs.src.tag}/Changes.rst";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
})
