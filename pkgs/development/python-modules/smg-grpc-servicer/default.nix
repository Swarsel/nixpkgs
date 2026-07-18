{
  lib,
  buildPythonPackage,
  fetchPypi,
  # dependencies
  grpcio,
  grpcio-health-checking,
  grpcio-reflection,
  # build-system
  setuptools,
  smg-grpc-proto,
}:
buildPythonPackage (finalAttrs: {
  pname = "smg-grpc-servicer";
  version = "0.5.5";

  # No tags on GitHub
  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-g3SCR/WjoSpxoq1a+Elvf9z+kAvb8nGgayMRMR/q4d8=";
    format = "setuptools";
    pname = "smg_grpc_servicer";
  };

  env.PYTHONDONTWRITEBYTECODE = 1;
  # no tests
  doCheck = false;

  postInstall = ''
    find $out -name __pycache__ -type d | xargs rm -rv
  '';

  __structuredAttrs = true;

  build-system = [
    setuptools
  ];

  dependencies = [
    grpcio
    grpcio-health-checking
    grpcio-reflection
    smg-grpc-proto
  ];

  pyproject = true;
  pythonImportsCheck = [ "smg_grpc_servicer" ];

  meta = {
    description = "SMG gRPC servicer implementations for LLM inference engines (vLLM, SGLang, MLX)";
    homepage = "https://github.com/lightseekorg/smg/tree/main/grpc_servicer";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ prince213 ];
  };
})
