{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  packaging,
  pyparsing,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage (finalAttrs: {
  pname = "pip-requirements-parser";
  version = "32.0.1";

  src = fetchFromGitHub {
    owner = "nexB";
    repo = "pip-requirements-parser";
    tag = "v${finalAttrs.version}";
    hash = "sha256-UMrwDXxk+sD3P2jk7s95y4OX6DRBjWWZZ8IhkR6tnZ4=";
  };

  patches = [
    # packaging 26.0 changed the string representation of requirements with
    # URLs to contain an extra space before the `@`.
    # https://github.com/pypa/packaging/pull/953
    # https://github.com/aboutcode-org/pip-requirements-parser/issues/27
    # https://github.com/aboutcode-org/pip-requirements-parser/pull/28
    ./packaging-26.patch
  ];

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    packaging
    pyparsing
  ];

  disabledTests = [
    "test_RequirementsFile_to_dict"
    "test_RequirementsFile_dumps_unparse"
    "test_legacy_version_is_deprecated"
  ];

  dontConfigure = true;
  pyproject = true;
  pythonImportsCheck = [ "pip_requirements_parser" ];

  meta = {
    description = "Module to parse pip requirements";
    homepage = "https://github.com/nexB/pip-requirements-parser";
    changelog = "https://github.com/nexB/pip-requirements-parser/blob/${finalAttrs.src.tag}/CHANGELOG.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
