{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  hypothesis,
  # native darwin dependencies
  libiconv,
  # tests
  pytestCheckHook,
  # build-system
  rustPlatform,
}:

buildPythonPackage rec {
  pname = "css-inline";
  version = "0.21.0";

  src = fetchFromGitHub {
    owner = "Stranger6667";
    repo = "css-inline";
    rev = "python-v${version}";
    hash = "sha256-hXrcomE//BScA395zXSKQayeRn8G8ivfcIJkIKu+PUE=";
  };

  postPatch = ''
    cd bindings/python
    ln -s ${./Cargo.lock} Cargo.lock

    # don't rebuild std
    rm .cargo/config.toml
  '';

  nativeBuildInputs = [
    rustPlatform.cargoSetupHook
    rustPlatform.maturinBuildHook
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isDarwin [
    libiconv
  ];

  nativeCheckInputs = [
    hypothesis
    pytestCheckHook
  ];

  # call `cargo build --release` in bindings/python and copy the
  # resulting lock file
  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit pname version src;

    postPatch = ''
      cd bindings/python
      ln -s ${./Cargo.lock} Cargo.lock
    '';

    hash = "sha256-Nj7DA20qCvSQ6EhC6GO+25TBqPeAf3SV/gmpRISgWtM=";
  };

  disabledTests = [
    # fails to connect to local server
    "test_cache"
    "test_remote_stylesheet"
  ]
  ++ lib.optionals (stdenv.hostPlatform.isDarwin) [
    # pyo3_runtime.PanicException: event loop thread panicked
    "test_invalid_href"
  ];

  pyproject = true;
  pythonImportsCheck = [ "css_inline" ];

  meta = {
    description = "Inline CSS into style attributes";
    homepage = "https://github.com/Stranger6667/css-inline";
    changelog = "https://github.com/Stranger6667/css-inline/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hexa ];
  };
}
