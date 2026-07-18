{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # tests
  catalogue,
  hypothesis,
  # passthru
  nix-update-script,
  numpy,
  pydantic,
  pytestCheckHook,
  # build-system
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "confection";
  version = "1.3.3";

  src = fetchFromGitHub {
    owner = "explosion";
    repo = "confection";
    tag = "release-v${finalAttrs.version}";
    hash = "sha256-64QwxK0Rl67n5vb/CuRJw/42A/SE9/Q5gtqITggYqhg=";
  };

  nativeCheckInputs = [
    catalogue
    hypothesis
    numpy
    pydantic
    pytestCheckHook
  ];

  build-system = [
    setuptools
  ];

  pyproject = true;
  pythonImportsCheck = [ "confection" ];

  passthru = {
    updateScript = nix-update-script {
      extraArgs = [
        "--version-regex"
        "release-v(.*)"
      ];
    };
  };

  meta = {
    description = "Library that offers a configuration system";
    homepage = "https://github.com/explosion/confection";
    changelog = "https://github.com/explosion/confection/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
