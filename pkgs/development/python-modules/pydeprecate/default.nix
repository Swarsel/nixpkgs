{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # cli
  fire,
  # optional-dependencies
  # audit
  packaging,
  # tests
  pytest-asyncio,
  pytestCheckHook,
  pythonOlder,
  rich,
  scikit-learn,
  # build-system
  setuptools,
  # dependencies
  typing-extensions,
}:

buildPythonPackage (finalAttrs: {
  pname = "pyDeprecate";
  version = "0.9.0";

  src = fetchFromGitHub {
    owner = "Borda";
    repo = "pyDeprecate";
    tag = "v${finalAttrs.version}";
    hash = "sha256-M3h5m+MqUYl8902YUqKqPfLpZXF3yQjlXP8f0ehnHds=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytestCheckHook
    scikit-learn
    typing-extensions
  ]
  ++ finalAttrs.passthru.optional-dependencies.cli;

  __structuredAttrs = true;

  build-system = [
    setuptools
  ];

  dependencies = lib.optionals (pythonOlder "3.13") [
    typing-extensions
  ];

  optional-dependencies = {
    audit = [
      packaging
    ];

    cli = [
      fire
      rich
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "deprecate" ];

  meta = {
    description = "Module for marking deprecated functions or classes and re-routing to the new successors' instance";
    homepage = "https://borda.github.io/pyDeprecate/";
    changelog = "https://github.com/Borda/pyDeprecate/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ SomeoneSerge ];
    downloadPage = "https://github.com/Borda/pyDeprecate";
  };
})
