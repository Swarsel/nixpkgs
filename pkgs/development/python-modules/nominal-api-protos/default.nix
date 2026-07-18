{
  lib,
  buildPythonPackage,
  fetchPypi,
  grpcio,
  grpcio-tools,
  protobuf,
  setuptools,
}:

buildPythonPackage rec {
  pname = "nominal-api-protos";
  version = "0.1073.0";

  # nixpkgs-update: no auto update
  src = fetchPypi {
    inherit version;
    hash = "sha256-jI7V34IyfY6bwzUvcOi6tdQI+OkJRMdhmNq0rosMjR4=";
    pname = "nominal_api_protos";
  };

  build-system = [ setuptools ];

  dependencies = [
    protobuf
    grpcio
    grpcio-tools
  ];

  pyproject = true;
  pythonImportsCheck = [ "nominal_api_protos" ];

  meta = {
    description = "Generated protobuf client for the Nominal API";
    homepage = "https://pypi.org/project/nominal-api-protos/";
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [ alkasm ];
  };
}
