{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  latex2mathml,
  pygments,
  pytest7CheckHook,
  setuptools,
  wavedrom,
}:

buildPythonPackage rec {
  pname = "markdown2";
  version = "2.5.5";

  src = fetchFromGitHub {
    owner = "trentm";
    repo = "python-markdown2";
    tag = version;
    hash = "sha256-h0vzv59RsceTZSvFF9DX5D6YanAKMTG3cNc1napXMyI=";
  };

  nativeCheckInputs = [ pytest7CheckHook ];
  build-system = [ setuptools ];

  optional-dependencies = {
    all = lib.concatAttrValues (lib.removeAttrs optional-dependencies [ "all" ]);
    code_syntax_highlighting = [ pygments ];
    latex = [ latex2mathml ];
    wavedrom = [ wavedrom ];
  };

  pyproject = true;
  pythonImportsCheck = [ "markdown2" ];

  meta = {
    description = "Fast and complete Python implementation of Markdown";
    homepage = "https://github.com/trentm/python-markdown2";
    changelog = "https://github.com/trentm/python-markdown2/blob/${src.tag}/CHANGES.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hbunke ];
    mainProgram = "markdown2";
  };
}
