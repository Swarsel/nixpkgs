{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  cargo,
  freezegun,
  hypothesis,
  libiconv,
  nix-update-script,
  pytest-mypy-plugins,
  pytestCheckHook,
  rustPlatform,
  rustc,
  setuptools,
  setuptools-rust,
  time-machine,
}:

buildPythonPackage rec {
  pname = "whenever";
  version = "0.10.2";

  src = fetchFromGitHub {
    owner = "ariebovenberg";
    repo = "whenever";
    tag = version;
    hash = "sha256-D3jNrxNTBbSheymnI72xAhdvvRzsbjIk+Gp82X7AkdU=";
  };

  buildInputs = lib.optionals stdenv.hostPlatform.isDarwin [
    libiconv
  ];

  # a bunch of failures, including an assumption of what the timezone on the host is
  # TODO: try enabling on bump
  doCheck = false;

  nativeCheckInputs = [
    pytestCheckHook
    pytest-mypy-plugins
    # pytest-benchmark # developer sanity check, should not block distribution
    hypothesis
    freezegun
    time-machine
  ];

  build-system = [
    setuptools
    setuptools-rust
    rustPlatform.cargoSetupHook
    cargo
    rustc
  ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit src;
    hash = "sha256-bmKUeVZwaqCN81v1YDnz66ZsUE8VTMBHlph6ZootKu8=";
  };

  disabledTestPaths = [
    # benchmarks
    "benchmarks/python/test_date.py"
    "benchmarks/python/test_instant.py"
    "benchmarks/python/test_local_datetime.py"
    "benchmarks/python/test_zoned_datetime.py"
  ];

  pyproject = true;
  pythonImportsCheck = [ "whenever" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Strict, predictable, and typed datetimes";
    homepage = "https://github.com/ariebovenberg/whenever";
    changelog = "https://github.com/ariebovenberg/whenever/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ pbsds ];
  };
}
