{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  cmake,
  cryptography,
  dnspython,
  pytest-asyncio,
  pytest-mock,
  pytestCheckHook,
  rustPlatform,
}:

buildPythonPackage (finalAttrs: {
  pname = "qh3";
  version = "1.9.3";

  src = fetchFromGitHub {
    owner = "jawah";
    repo = "qh3";
    tag = "v${finalAttrs.version}";
    hash = "sha256-m77m+uw6tntW+YEo0+hKZx8EePNcoivBZC84X7RDu5o=";
  };

  nativeBuildInputs = [
    cmake
    rustPlatform.bindgenHook
    rustPlatform.cargoSetupHook
    rustPlatform.maturinBuildHook
  ];

  env.NIX_CFLAGS_COMPILE = toString (
    lib.optionals stdenv.cc.isGNU [
      "-Wno-error=stringop-overflow"
    ]
  );

  nativeCheckInputs = [
    cryptography
    dnspython
    pytest-asyncio
    pytest-mock
    pytestCheckHook
  ];

  preCheck = ''
    # import from $out
    rm -r qh3
  '';

  __darwinAllowLocalNetworking = true;

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version src;
    hash = "sha256-mQ7kRXi5dqSJ1D58rZivKVO6j3SC+9GkDZkErU21cQc=";
  };

  disabledTests = lib.optionals stdenv.hostPlatform.isDarwin [
    # ConnectionError
    "test_connect_and_serve_ipv4"
    "test_ech_accepted"
    "test_grease_ech_no_rejection"
  ];

  dontUseCmakeConfigure = true;
  pyproject = true;
  pythonImportsCheck = [ "qh3" ];

  meta = {
    description = "Lightweight QUIC and HTTP/3 implementation in Python";
    homepage = "https://github.com/jawah/qh3";
    changelog = "https://github.com/jawah/qh3/blob/${finalAttrs.src.tag}/CHANGELOG.rst";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
})
