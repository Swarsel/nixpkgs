{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  dirty-equals,
  libiconv,
  pytest-benchmark,
  pytestCheckHook,
  rustPlatform,
}:

buildPythonPackage rec {
  pname = "rtoml";
  version = "0.10";

  src = fetchFromGitHub {
    owner = "samuelcolvin";
    repo = "rtoml";
    rev = "v${version}";
    hash = "sha256-1movtKMQkQ6PEpKpSkK0Oy4AV0ee7XrS0P9m6QwZTaM=";
  };

  buildInputs = [ libiconv ];

  nativeCheckInputs = [
    dirty-equals
    pytest-benchmark
    pytestCheckHook
  ];

  preCheck = ''
    rm -rf rtoml
  '';

  build-system = with rustPlatform; [
    cargoSetupHook
    maturinBuildHook
  ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit pname version src;
    hash = "sha256-/elui0Rf3XwvD2jX+NGoJgf9S3XSp16qzdwkGZbKaZg=";
  };

  disabledTests = [
    # TypeError: loads() got an unexpected keyword argument 'name'
    "test_load_data_toml"
  ];

  pyproject = true;
  pytestFlags = [ "--benchmark-disable" ];
  pythonImportsCheck = [ "rtoml" ];

  meta = {
    description = "Rust based TOML library for Python";
    homepage = "https://github.com/samuelcolvin/rtoml";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
