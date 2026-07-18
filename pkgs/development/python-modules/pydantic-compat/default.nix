{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  gitMinimal,
  hatch-vcs,
  hatchling,
  importlib-metadata,
  pydantic,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "pydantic-compat";
  version = "0.1.2";

  src = fetchFromGitHub {
    owner = "pyapp-kit";
    repo = "pydantic-compat";
    tag = "v${version}";
    hash = "sha256-YJUfWu+nyGlwpJpxYghCKzj3CasdAaqYoNVCcfo/7YE=";
    leaveDotGit = true;
  };

  nativeBuildInputs = [
    gitMinimal
  ];

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    hatch-vcs
    hatchling
  ];

  dependencies = [
    importlib-metadata
    pydantic
  ];

  pyproject = true;

  pytestFlags = [
    # pydantic.warnings.PydanticDeprecatedSince211: Accessing this attribute on the instance is
    # deprecated, and will be removed in Pydantic V3. Instead, you should access this attribute from
    # the model class. Deprecated in Pydantic V2.11 to be removed in V3.0.
    "-Wignore::pydantic.warnings.PydanticDeprecatedSince211"
    "-Wignore::pydantic.warnings.PydanticDeprecatedSince212"
  ];

  pythonImportsCheck = [ "pydantic_compat" ];

  meta = {
    description = "Compatibility layer for pydantic v1/v2";
    homepage = "https://github.com/pyapp-kit/pydantic-compat";
    changelog = "https://github.com/pyapp-kit/pydantic-compat/releases/tag/v${version}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ fab ];
  };
}
