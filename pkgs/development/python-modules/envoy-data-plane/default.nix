{
  lib,
  # dependencies
  betterproto,
  buildPythonPackage,
  fetchPypi,
  grpcio-tools,
  # build-system
  poetry-core,
}:

buildPythonPackage (finalAttrs: {
  pname = "envoy-data-plane";
  version = "1.0.3";

  # Version 2.0.0 appears to be an empty archive and apache-beam requires envoy-data-planes<2.0.0
  # nixpkgs-update: no auto update
  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-UkSrtENDXjEtvEJldgZ5UHHkxK3rOqV3mmifrLGo538=";
    pname = "envoy_data_plane";
  };

  # No tests
  doCheck = false;

  build-system = [
    poetry-core
  ];

  dependencies = [
    betterproto
    grpcio-tools
  ];

  pyproject = true;
  pythonImportsCheck = [ "envoy_data_plane" ];

  pythonRelaxDeps = [
    "betterproto"
  ];

  meta = {
    description = "Python dataclasses for the Envoy Data-Plane-API";
    homepage = "https://pypi.org/project/envoy_data_plane/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
})
