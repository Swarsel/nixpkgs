{
  lib,
  buildPythonPackage,
  cacert,
  fetchPypi,
  hypothesis,
  nix-update-script,
  pytestCheckHook,
  rustPlatform,
}:

buildPythonPackage rec {
  pname = "jsonschema-rs";
  version = "0.46.5";

  # Fetching from Pypi, because there is no Cargo.lock in the GitHub repo.
  src = fetchPypi {
    inherit version;
    hash = "sha256-hX434HWi2fbyPepYpVmlW2Y9OHmiUhcABLVpBz2rHvM=";
    pname = "jsonschema_rs";
  };

  nativeBuildInputs = with rustPlatform; [
    cargoSetupHook
    maturinBuildHook
  ];

  nativeCheckInputs = [
    hypothesis
    pytestCheckHook
  ];

  preCheck = ''
    # reqwest fails to build its HTTP client on Linux without a CA bundle
    # ("No CA certificates were loaded from the system").
    export SSL_CERT_FILE="${cacert}/etc/ssl/certs/ca-bundle.crt"
  '';

  __darwinAllowLocalNetworking = true;

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit pname version src;
    hash = "sha256-HnrbyfuKIaYKs3ux8Du/PabPNpNu1v37Qm/5gJM6arw=";
  };

  # Need the official JSON Schema Test Suite, which is fetched as a git
  # submodule and not bundled in the sdist.
  disabledTestPaths = [
    "crates/jsonschema-py/tests-py/test_annotation_suite.py"
    "crates/jsonschema-py/tests-py/test_suite.py"
  ];

  pyproject = true;
  pythonImportsCheck = [ "jsonschema_rs" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "High-performance JSON Schema validator for Python";
    homepage = "https://github.com/Stranger6667/jsonschema/tree/master/crates/jsonschema-py";
    changelog = "https://github.com/Stranger6667/jsonschema/blob/python-v${version}/crates/jsonschema-py/CHANGELOG.md";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      DutchGerman
      friedow
    ];
  };
}
