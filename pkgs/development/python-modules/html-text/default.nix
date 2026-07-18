{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  lxml,
  lxml-html-clean,
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "html-text";
  version = "0.7.1";

  src = fetchFromGitHub {
    owner = "zytedata";
    repo = "html-text";
    tag = finalAttrs.version;
    hash = "sha256-KLWgdVHGYRiQ61hMNx+Kcx9mE7d/TsBe110TfCe+ejU=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ hatchling ];

  dependencies = [
    lxml
    lxml-html-clean
  ];

  pyproject = true;
  pythonImportsCheck = [ "html_text" ];

  meta = {
    description = "Extract text from HTML";
    homepage = "https://github.com/zytedata/html-text";
    changelog = "https://github.com/zytedata/html-text/blob/${finalAttrs.version}/CHANGES.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ambroisie ];
  };
})
