{
  lib,
  fetchFromGitHub,
  # tests
  attrs,
  buildPythonPackage,
  # for passthru.tests
  enrich,
  httpie,
  # optional-dependencies
  ipywidgets,
  # dependencies
  markdown-it-py,
  # build-system
  poetry-core,
  pygments,
  pytestCheckHook,
  rich-rst,
  textual,
  which,
}:

buildPythonPackage (finalAttrs: {
  pname = "rich";
  version = "15.0.0";

  src = fetchFromGitHub {
    owner = "Textualize";
    repo = "rich";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Uk3r6aYhrjYJ8GrMKfdlv3/muK/uUynd4pd1yWCwSOM=";
  };

  nativeCheckInputs = [
    attrs
    pytestCheckHook
    which
  ];

  build-system = [ poetry-core ];

  dependencies = [
    markdown-it-py
    pygments
  ];

  optional-dependencies = {
    jupyter = [ ipywidgets ];
  };

  pyproject = true;
  pythonImportsCheck = [ "rich" ];

  passthru.tests = {
    inherit
      enrich
      httpie
      rich-rst
      textual
      ;
  };

  meta = {
    description = "Render rich text, tables, progress bars, syntax highlighting, markdown and more to the terminal";
    homepage = "https://github.com/Textualize/rich";
    changelog = "https://github.com/Textualize/rich/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ris ];
  };
})
