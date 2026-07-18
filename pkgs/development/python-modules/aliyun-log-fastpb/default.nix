{
  lib,
  buildPythonPackage,
  cargo,
  fetchPypi,
  nix-update-script,
  rustPlatform,
  rustc,
}:

buildPythonPackage (finalAttrs: {
  pname = "aliyun-log-fastpb";
  version = "0.3.0";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-dG4/tVx+brlxXoUqdcrFck6Zh3jAmtF+Aiso63axp0E=";
    pname = "aliyun_log_fastpb";
  };

  # Missing dependency logs_pb2
  doCheck = false;
  __structuredAttrs = true;

  build-system = [
    cargo
    rustPlatform.cargoSetupHook
    rustPlatform.maturinBuildHook
    rustc
  ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version src;
    hash = "sha256-WPjJalEd/3jrx8pFP/RbHqQqMuloemTLeVjXjpOoJsQ=";
  };

  pyproject = true;
  pythonImportsCheck = [ "aliyun_log_fastpb" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Fast protobuf serialization for Aliyun Log using PyO3 and quick-protobuf";
    homepage = "https://pypi.org/project/aliyun-log-fastpb";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
