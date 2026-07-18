{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  grpcio,
  grpcio-tools,
  # build
  hatchling,
  protobuf,
}:

buildPythonPackage (finalAttrs: {
  pname = "logic2-automation";
  version = "1.0.11";

  src = fetchFromGitHub {
    owner = "saleae";
    repo = "logic2-automation";
    tag = "v${finalAttrs.version}";
    hash = "sha256-e0UvRwUs+rKFF3ky8bnHV22ZA9sU+AoghcMui2pIzQ0=";
  };

  preBuild = "./build.sh";
  # Tests require the unfree saleae-logic-2 package, plus gRPC server which is not packaged, yet.
  doCheck = false;

  build-system = [
    hatchling
  ];

  dependencies = [
    grpcio
    grpcio-tools
    protobuf
  ];

  pyproject = true;
  pythonImportsCheck = [ "saleae.automation" ];
  sourceRoot = "source/python";

  meta = {
    description = "Automation interface for Saleae Logic 2 software";
    homepage = "https://github.com/saleae/logic2-automation";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ krishnans2006 ];
  };
})
