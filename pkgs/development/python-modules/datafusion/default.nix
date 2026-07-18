{
  lib,
  stdenv,
  fetchFromGitHub,
  # tests
  arro3-core,
  buildPythonPackage,
  nanoarrow,
  numpy,
  # buildInputs
  protobuf,
  # nativeBuildInputs
  protoc,
  # dependencies
  pyarrow,
  pytest-asyncio,
  pytestCheckHook,
  rustPlatform,
  typing-extensions,
}:

buildPythonPackage (finalAttrs: {
  pname = "datafusion";
  # WARNING: Ensure rerun-sdk is compatible with this version of datafusion
  version = "53.0.0";

  src = fetchFromGitHub {
    owner = "apache";
    repo = "datafusion-python";
    tag = finalAttrs.version;
    hash = "sha256-3plgAJuh2rrnvzkQVy3gUgEoHHT4FSjDp5DZx1keD+g=";
    # Fetch arrow-testing and parquet-testing (tests assets)
    fetchSubmodules = true;
    name = "datafusion-source";
  };

  nativeBuildInputs = with rustPlatform; [
    cargoSetupHook
    maturinBuildHook
    protoc
  ];

  buildInputs = [
    protobuf
  ];

  nativeCheckInputs = [
    arro3-core
    nanoarrow
    numpy
    pytest-asyncio
    pytestCheckHook
  ];

  preCheck = ''
    rm -rf python/datafusion
  '';

  __structuredAttrs = true;

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname src version;
    hash = "sha256-kHGlUaPNSs1Nh3HCU+yUVQq/IXp9PUwpDmfAon8eRBk=";
  };

  dependencies = [
    pyarrow
    typing-extensions
  ];

  disabledTests = [
    # Exception: DataFusion error (requires internet access)
    "test_register_http_csv"
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    # Flaky: Failed: Query was not interrupted; got error: None
    "test_collect_interrupted"
  ];

  pyproject = true;

  pythonImportsCheck = [
    "datafusion"
    "datafusion._internal"
  ];

  meta = {
    description = "Extensible query execution framework";

    longDescription = ''
      DataFusion is an extensible query execution framework, written in Rust,
      that uses Apache Arrow as its in-memory format.
    '';

    homepage = "https://arrow.apache.org/datafusion/";
    changelog = "https://github.com/apache/datafusion-python/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = with lib.licenses; [ asl20 ];
    maintainers = with lib.maintainers; [ cpcloud ];
  };
})
