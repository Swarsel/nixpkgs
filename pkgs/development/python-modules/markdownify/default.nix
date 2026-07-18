{
  lib,
  fetchFromGitHub,
  beautifulsoup4,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
  six,
}:

buildPythonPackage (finalAttrs: {
  pname = "markdownify";
  version = "1.2.3";

  src = fetchFromGitHub {
    owner = "matthewwithanm";
    repo = "python-markdownify";
    tag = finalAttrs.version;
    hash = "sha256-zhkWkEFdDLVvA0xgFOG2PDXCTLZy+DWweuiiSVNUU80=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    beautifulsoup4
    six
  ];

  pyproject = true;
  pythonImportsCheck = [ "markdownify" ];

  meta = {
    description = "HTML to Markdown converter";
    homepage = "https://github.com/matthewwithanm/python-markdownify";
    changelog = "https://github.com/matthewwithanm/python-markdownify/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ McSinyx ];
    mainProgram = "markdownify";
  };
})
