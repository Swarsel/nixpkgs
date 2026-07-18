{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  markdown,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "mdx-truly-sane-lists";
  version = "1.3";

  src = fetchFromGitHub {
    owner = "radude";
    repo = "mdx_truly_sane_lists";
    tag = version;
    hash = "sha256-hPnqF1UA4peW8hzeFiMlsBPfodC1qJXETGoq2yUm7d4=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  dependencies = [ markdown ];
  enabledTestPaths = [ "mdx_truly_sane_lists/tests.py" ];
  pyproject = true;
  pythonImportsCheck = [ "mdx_truly_sane_lists" ];

  meta = {
    description = "Extension for Python-Markdown that makes lists truly sane";

    longDescription = ''
      Features custom indents for nested lists and fix for messy linebreaks and
      paragraphs between lists.
    '';

    homepage = "https://github.com/radude/mdx_truly_sane_lists";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ kaction ];
  };
}
