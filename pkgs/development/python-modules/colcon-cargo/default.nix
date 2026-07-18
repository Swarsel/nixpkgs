{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cargo,
  colcon,
  pytestCheckHook,
  rustfmt,
  scspell,
  setuptools,
  toml,
  writableTmpDirAsHomeHook,
}:
buildPythonPackage (finalAttrs: {
  pname = "colcon-cargo";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "colcon";
    repo = "colcon-cargo";
    tag = finalAttrs.version;
    hash = "sha256-jhc5mN4jnLk2zLj01sBm63acrku/FIexnIWCQ6GKDKA=";
  };

  nativeCheckInputs = [
    cargo
    pytestCheckHook
    scspell
    rustfmt
    writableTmpDirAsHomeHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    colcon
    toml
  ];

  disabledTestPaths = [
    # Skip the linter tests
    "test/test_flake8.py"
  ];

  disabledTests = [
    # Attempts to download https://index.crates.io/config.json at test time
    "test_build_and_test_package"
    "test_skip_pure_library_package"
  ];

  pyproject = true;

  pythonImportsCheck = [
    "colcon_cargo"
  ];

  meta = {
    description = "Extension for colcon-core to support Rust packages built with Cargo";
    homepage = "https://github.com/colcon/colcon-cargo";
    changelog = "https://github.com/colcon/colcon-cargo/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ guelakais ];
  };
})
