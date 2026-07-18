{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  click,
  poetry-core,
  pydantic,
  pydantic-core,
  pydantic-settings,
  pytest7CheckHook,
}:

buildPythonPackage rec {
  pname = "pydanclick";
  version = "0.5.1";

  src = fetchFromGitHub {
    owner = "felix-martel";
    repo = "pydanclick";
    tag = "v${version}";
    hash = "sha256-Cgjq+9j6v7KILjfhK+4Y5joZPU2/ufJiIsdAfnSG9x4=";
  };

  nativeCheckInputs = [
    # Still uses RaisesContext from pytest 7
    # https://github.com/felix-martel/pydanclick/issues/53
    pytest7CheckHook
    pydantic-settings
  ];

  build-system = [ poetry-core ];

  dependencies = [
    pydantic
    pydantic-core
    click
  ];

  disabledTests = [
    # No idea about these two failures
    "test_complex_types_example_help"
    "test_simple_example_with_invalid_args"
  ];

  pyproject = true;
  pythonImportsCheck = [ "pydanclick" ];

  meta = {
    description = "Add click options from a Pydantic model";
    homepage = "https://github.com/felix-martel/pydanclick";
    changelog = "https://github.com/felix-martel/pydanclick/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.erictapen ];
  };
}
