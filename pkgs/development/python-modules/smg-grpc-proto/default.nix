{
  lib,
  buildPythonPackage,
  fetchPypi,

  # build-system
  grpcio-tools,
  setuptools,
}:
buildPythonPackage (finalAttrs: {
  pname = "smg-grpc-proto";
  version = "0.4.10";

  # No tags on GitHub
  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-VBVhjSUuWitD0du9LB6uMFdgBw3SRzUwgUCu0Gp0hr4=";
    format = "setuptools";
    pname = "smg_grpc_proto";
  };

  env.PYTHONDONTWRITEBYTECODE = 1;
  # no tests
  doCheck = false;

  postInstall = ''
    find $out -name __pycache__ -type d | xargs rm -rv
  '';

  __structuredAttrs = true;

  build-system = [
    grpcio-tools
    setuptools
  ];

  pyproject = true;
  pythonImportsCheck = [ "smg_grpc_proto" ];

  meta = {
    description = "SMG gRPC proto definitions for SGLang, vLLM, TRT-LLM, and MLX";
    homepage = "https://github.com/lightseekorg/smg/tree/main/crates/grpc_client/python";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ prince213 ];
  };
})
