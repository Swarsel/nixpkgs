{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # build-system
  hatch-vcs,
  hatchling,
  # dependencies
  jax,
  # optional-dependencies
  pandas,
  # tests
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "jax-tap";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "arcueil";
    repo = "jax-tap";
    tag = "v${finalAttrs.version}";
    hash = "sha256-B6Y8+9FXLhHZwQ9ayomffP3P7Uz7zuL52oxzJwCE2hM=";
  };

  nativeCheckInputs = [
    pandas
    pytestCheckHook
  ];

  __structuredAttrs = true;

  build-system = [
    hatch-vcs
    hatchling
  ];

  dependencies = [
    jax
  ];

  optional-dependencies = {
    pandas = [
      pandas
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "jaxtap" ];

  meta = {
    description = "Make print-debugging great again";
    homepage = "https://github.com/arcueil/jax-tap";
    changelog = "https://github.com/arcueil/jax-tap/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
})
