{
  lib,
  stdenv,
  buildPythonPackage,
  cargo,
  fetchPypi,
  nix-update-script,
  openssl,
  pkg-config,
  pytest-asyncio,
  pytestCheckHook,
  rustPlatform,
  rustc,
}:

buildPythonPackage (finalAttrs: {
  pname = "blasthttp";
  version = "0.9.0";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-JuoGy+QdBsVPMtD0T4Y/NSoeJcO7dwg3HmpqHxTxCIc=";
  };

  postPatch = ''
    # The bundled .cargo/config.toml sets OPENSSL_DIR to a relative path
    rm .cargo/config.toml
  '';

  buildInputs = [ openssl ];

  env = {
    OPENSSL_NO_VENDOR = "1";
  };

  nativeCheckInputs = [
    openssl
    pytest-asyncio
    pytestCheckHook
  ];

  __darwinAllowLocalNetworking = true;
  __structuredAttrs = true;

  build-system = [
    cargo
    pkg-config
    rustPlatform.cargoSetupHook
    rustPlatform.maturinBuildHook
    rustc
  ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version src;
    hash = "sha256-1+OFAD9n8JntZSV+PZbYLPRM/XDlFwgrEMFGv/LzTN8=";
  };

  disabledTestPaths = lib.optionals stdenv.hostPlatform.isDarwin [
    "tests/python/test_ssl_verify.py"
    "tests/python/test_response_api.py"
  ];

  disabledTests = lib.optionals stdenv.hostPlatform.isDarwin [
    "test_redirect_onto_proxied_host_reevaluates_no_proxy"
    "test_redirect_onto_no_proxy_host_reevaluates_to_direct"
  ];

  pyproject = true;
  pythonImportsCheck = [ "blasthttp" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Offensive-first HTTP library";
    homepage = "https://pypi.org/project/blasthttp";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ fab ];
  };
})
