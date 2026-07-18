{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  grpcio,
  poetry-core,
  protobuf,
  pytest-asyncio,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "grpc-interceptor";
  version = "0.15.4";

  src = fetchFromGitHub {
    owner = "d5h-foss";
    repo = "grpc-interceptor";
    tag = "v${version}";
    hash = "sha256-GJkVCslPXShJNDrqhFtCsAK5+VaG8qFJo0RQTsiMIFY=";
  };

  nativeBuildInputs = [ poetry-core ];

  propagatedBuildInputs = [
    grpcio
    protobuf
  ];

  nativeCheckInputs = [
    pytest-asyncio
    pytestCheckHook
  ];

  __darwinAllowLocalNetworking = true;
  pyproject = true;
  pythonImportsCheck = [ "grpc_interceptor" ];

  meta = {
    description = "Simplified gRPC interceptors";

    longDescription = ''
      Simplified Python gRPC interceptors.

      The Python gRPC package provides service interceptors, but they're a bit
      hard to use because of their flexibility. The gRPC interceptors don't
      have direct access to the request and response objects, or the service
      context. Access to these are often desired, to be able to log data in the
      request or response, or set status codes on the context.
    '';

    homepage = "https://github.com/d5h-foss/grpc-interceptor";
    changelog = "https://github.com/d5h-foss/grpc-interceptor/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ tomaskala ];
  };
}
