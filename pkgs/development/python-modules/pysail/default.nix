{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  nix-update-script,
  protobuf,
  protoc,
  pysail,
  rustPlatform,
  testers,
}:

buildPythonPackage (finalAttrs: {
  pname = "pysail";
  version = "0.6.6";

  src = fetchFromGitHub {
    owner = "lakehq";
    repo = "sail";
    tag = "v${finalAttrs.version}";
    hash = "sha256-DpkoC7uShuReOBN5tjvcCSH1LH/e+fj3gp47idsEGEg=";
  };

  # The `generate-import-lib` PyO3 feature only matters when building Windows
  # import libraries; on other platforms it just pulls in the `python3-dll-a`
  # crate, which is not vendored. Drop it so the offline maturin build resolves.
  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail '"pyo3/generate-import-lib",' ""
  '';

  nativeBuildInputs = with rustPlatform; [
    cargoSetupHook
    maturinBuildHook
    protoc
  ];

  buildInputs = [
    protobuf
  ];

  # The test suite requires a running Spark Connect server and many
  # heavyweight optional dependencies (pyspark-client, duckdb, ...).
  doCheck = false;

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname src version;
    hash = "sha256-byjxrJN+Q+Rn3pq/FWXxzheZyUs+aoTvfileahqinuA=";
  };

  pyproject = true;

  pythonImportsCheck = [
    "pysail"
    "pysail._native"
  ];

  passthru = {
    tests.version = testers.testVersion {
      package = pysail;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Python bindings for Sail, a Spark-compatible compute engine on Apache Arrow and DataFusion";
    homepage = "https://github.com/lakehq/sail";
    changelog = "https://github.com/lakehq/sail/blob/${finalAttrs.src.tag}/docs/reference/changelog/index.md";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.davidlghellin ];
    mainProgram = "sail";
  };
})
