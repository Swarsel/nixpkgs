{
  lib,
  buildPythonPackage,
  fetchPypi,

  # build-system
  flit-core,

  # tests
  packaging,
  pretend,
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "packaging";
  version = "26.2";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-/0Uv9aPoKM4RAZD+/xF4ux8uoigfogdarbmHwvsiFmE=";
  };

  nativeBuildInputs = [ flit-core ];
  # Prevent circular dependency with pytest
  doCheck = false;

  nativeCheckInputs = [
    pytestCheckHook
    pretend
  ];

  pyproject = true;

  pythonImportsCheck = [
    "packaging"
    "packaging.metadata"
    "packaging.requirements"
    "packaging.specifiers"
    "packaging.tags"
    "packaging.version"
  ];

  passthru.tests = packaging.overridePythonAttrs (_: {
    doCheck = true;
  });

  meta = {
    description = "Core utilities for Python packages";
    homepage = "https://packaging.pypa.io/";
    changelog = "https://github.com/pypa/packaging/blob/${finalAttrs.version}/CHANGELOG.rst";

    license = with lib.licenses; [
      bsd2
      asl20
    ];

    maintainers = with lib.maintainers; [ bennofs ];
    downloadPage = "https://github.com/pypa/packaging";
    teams = [ lib.teams.python ];
  };
})
