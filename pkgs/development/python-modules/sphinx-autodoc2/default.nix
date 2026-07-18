{
  lib,
  fetchFromGitHub,
  astroid,
  buildPythonPackage,
  defusedxml,
  fetchDebianPatch,
  flit-core,
  pytest-regressions,
  pytestCheckHook,
  sphinx,
  typer,
  typing-extensions,
}:

buildPythonPackage (finalAttrs: {
  pname = "sphinx-autodoc2";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "sphinx-extensions2";
    repo = "sphinx-autodoc2";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Wu079THK1mHVilD2Fx9dIzuIOOYOXpo/EMxVczNutCI=";
  };

  patches = [
    # compatibility with astroid 4, see: https://github.com/sphinx-extensions2/sphinx-autodoc2/pull/93
    (fetchDebianPatch {
      inherit (finalAttrs) version;
      pname = "python-sphinx-autodoc2";
      debianRevision = "9";
      hash = "sha256-tRWDee30GSQ+AobCAHdtw65B6YyRpzn7kW5rzK7/QOk=";
      patch = "astroid-4.patch";
    })
  ];

  nativeCheckInputs = [
    pytestCheckHook
    pytest-regressions
    sphinx
    defusedxml
  ];

  preCheck = ''
    # make sphinx_path an alias of pathlib.Path, since sphinx_path was removed in Sphinx v7.2.0
    substituteInPlace tests/test_render.py --replace-fail \
        'from sphinx.testing.util import path as sphinx_path' \
        'sphinx_path = Path'
  '';

  build-system = [ flit-core ];

  dependencies = [
    astroid
    typing-extensions

    # cli deps
    typer
  ];

  disabledTests = [
    # some generated files differ in newer versions of Sphinx
    "test_sphinx_build_directives"
  ];

  pyproject = true;
  pythonImportsCheck = [ "autodoc2" ];

  meta = {
    description = "Sphinx extension that automatically generates API documentation for your Python packages";
    homepage = "https://github.com/sphinx-extensions2/sphinx-autodoc2";
    changelog = "https://github.com/sphinx-extensions2/sphinx-autodoc2/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ tomasajt ];
    mainProgram = "autodoc2";
  };
})
