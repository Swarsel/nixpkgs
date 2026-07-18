{
  lib,
  fetchFromGitHub,
  buildPackages,
  buildPythonPackage,
  # nativeBuildInputs
  cargo,
  # build-system
  maturin,
  # dependencies
  nexusrpc,
  nix-update-script,
  # passthru
  nixosTests,
  protobuf,
  rustPlatform,
  rustc,
  types-protobuf,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "temporalio";
  version = "1.30.0";

  src = fetchFromGitHub {
    owner = "temporalio";
    repo = "sdk-python";
    tag = version;
    hash = "sha256-8bCkm2b66CUSfIri0PhDLCijFSQR82wzAQKjdlk8VBg=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cargo
    rustPlatform.cargoSetupHook
    rustPlatform.maturinBuildHook
    rustc
  ];

  env.PROTOC = "${lib.getExe buildPackages.protobuf}";

  build-system = [
    maturin
  ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit
      pname
      version
      src
      cargoRoot
      ;

    hash = "sha256-CnQ3xwja9ZnQQy7OEwtX/WtYsPtyREBkXpjx3JAeBKo=";
  };

  cargoRoot = "temporalio/bridge";

  dependencies = [
    nexusrpc
    protobuf
    types-protobuf
    typing-extensions
  ];

  pyproject = true;

  pythonImportsCheck = [
    "temporalio"
    "temporalio.bridge.temporal_sdk_bridge"
    "temporalio.client"
    "temporalio.worker"
  ];

  pythonRelaxDeps = [
    "protobuf"
  ];

  passthru = {
    tests = { inherit (nixosTests) temporal; };
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Temporal Python SDK";
    homepage = "https://temporal.io/";
    changelog = "https://github.com/temporalio/sdk-python/releases/tag/${version}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      jpds
      levigross
    ];
  };
}
