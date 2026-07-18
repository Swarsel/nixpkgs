{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cargo,
  grpc-interceptor,
  grpcio,
  httpx,
  pytest-asyncio,
  pytest-mock,
  pytestCheckHook,
  pythonAtLeast,
  rustPlatform,
  rustc,
  syrupy,
}:

buildPythonPackage rec {
  pname = "qcs-api-client-common";
  version = "0.15.0";

  src = fetchFromGitHub {
    owner = "rigetti";
    repo = "qcs-api-client-rust";
    tag = "common/v${version}";
    hash = "sha256-ksB71Vd9PbKAHll2Y5VrCspsyUyhXwthHl2yVl6MQ7U=";
  };

  nativeBuildInputs = [
    cargo
    rustPlatform.cargoSetupHook
    rustPlatform.maturinBuildHook
    rustc
  ];

  nativeCheckInputs = [
    pytest-asyncio
    pytest-mock
    pytestCheckHook
    syrupy
  ];

  preCheck = ''
    cd ${buildAndTestSubdir}
  '';

  buildAndTestSubdir = "qcs-api-client-common";

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit pname version src;
    hash = "sha256-QvMeCzpHGMVjqYs0i3gpzY6Zk4rGiXyTopzaQMLWBcA=";
  };

  dependencies = [
    grpc-interceptor
    grpcio
    httpx
  ];

  disabledTests = lib.optionals (pythonAtLeast "3.14") [
    # asyncio.Future() in sync fixture has no implicit event loop on 3.14
    "test_refresh_interceptor"
  ];

  pyproject = true;

  meta = {
    description = "Contains core QCS client functionality and middleware implementations";
    homepage = "https://github.com/rigetti/qcs-api-client-rust/tree/main/qcs-api-client-common";
    changelog = "https://github.com/rigetti/qcs-api-client-rust/blob/${src.tag}/qcs-api-client-common/CHANGELOG-py.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
