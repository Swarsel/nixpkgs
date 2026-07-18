{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  defusedxml,
  flit-core,
  pytest,
  pytestCheckHook,
  sphinx,
}:

buildPythonPackage rec {
  pname = "sphinx-pytest";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "chrisjsewell";
    repo = "sphinx-pytest";
    tag = "v${version}";
    hash = "sha256-z71IrUr3e2oAPeZMjUBwMwy2SkoAA3oxtK4+iR9vLEc=";
  };

  nativeBuildInputs = [ flit-core ];
  buildInputs = [ pytest ];
  propagatedBuildInputs = [ sphinx ];

  nativeCheckInputs = [
    defusedxml
    pytestCheckHook
  ];

  disabledTests = [
    # https://github.com/sphinx-extensions2/sphinx-pytest/issues/28
    "test_no_transforms"
  ];

  pyproject = true;
  pythonImportsCheck = [ "sphinx_pytest" ];

  meta = {
    description = "Helpful pytest fixtures for Sphinx extensions";
    homepage = "https://github.com/chrisjsewell/sphinx-pytest";
    changelog = "https://github.com/sphinx-extensions2/sphinx-pytest/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ loicreynier ];
  };
}
