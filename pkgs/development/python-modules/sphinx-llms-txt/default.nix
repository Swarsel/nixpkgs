{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
  sphinx,
}:
buildPythonPackage (finalAttrs: {
  pname = "sphinx-llms-txt";
  version = "0.7.1";

  src = fetchFromGitHub {
    owner = "jdillard";
    repo = "sphinx-llms-txt";
    tag = "v${finalAttrs.version}";
    hash = "sha256-9uj5UYl6/TppGd3zuGUpxiY9U6/65ffWDPKaX7ut4zg=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  __structuredAttrs = true;

  build-system = [
    setuptools
  ];

  dependencies = [
    sphinx
  ];

  pyproject = true;
  pythonImportsCheck = [ "sphinx_llms_txt" ];

  meta = {
    description = "llms.txt generator for Sphinx";
    homepage = "https://github.com/jdillard/sphinx-llms-txt";
    changelog = "https://github.com/jdillard/sphinx-llms-txt/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ felbinger ];
  };
})
