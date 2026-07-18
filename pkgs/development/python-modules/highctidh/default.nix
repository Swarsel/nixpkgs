{
  lib,
  buildPythonPackage,
  fetchFromCodeberg,
  gitUpdater,
  pytestCheckHook,
  setuptools,
}:
buildPythonPackage rec {
  pname = "highctidh";
  version = "1.0.2025051200";

  src = fetchFromCodeberg {
    owner = "vula";
    repo = "highctidh";
    tag = "v${version}";
    hash = "sha256-wGJv9UHAFfCOpTrr8THVk0DC+JUtj3gYYOf6o3EaSqg=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    setuptools
  ];

  pyproject = true;

  pythonImportsCheck = [
    "highctidh"
  ];

  sourceRoot = "${src.name}/src";

  passthru.updateScript = gitUpdater {
    rev-prefix = "v";
  };

  meta = {
    description = "Fork of high-ctidh as as a portable shared library with Python bindings";
    homepage = "https://codeberg.org/vula/highctidh";
    license = lib.licenses.publicDomain;

    maintainers = with lib.maintainers; [
      lorenzleutgeb
      mightyiam
    ];

    teams = with lib.teams; [ ngi ];
  };
}
