{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  importlib-metadata,
  pytestCheckHook,
  setuptools,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "docstring-to-markdown";
  version = "0.17";

  src = fetchFromGitHub {
    owner = "python-lsp";
    repo = "docstring-to-markdown";
    tag = "v${version}";
    hash = "sha256-conwwToBrlDL487zf2ldCOxFFKxP1a8LnU0KocI8riI=";
  };

  postPatch = ''
    sed -i -E '/--(cov|flake8)/d' setup.cfg
  '';

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    importlib-metadata
    typing-extensions
  ];

  pyproject = true;
  pythonImportsCheck = [ "docstring_to_markdown" ];

  meta = {
    description = "On the fly conversion of Python docstrings to markdown";
    homepage = "https://github.com/python-lsp/docstring-to-markdown";
    changelog = "https://github.com/python-lsp/docstring-to-markdown/releases/tag/${src.tag}";
    license = lib.licenses.lgpl2Plus;
    maintainers = with lib.maintainers; [ doronbehar ];
  };
}
