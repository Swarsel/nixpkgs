{
  lib,
  buildPythonPackage,
  fetchPypi,
  netaddr,
  oslo-concurrency,
  oslo-config,
  oslo-serialization,
  oslo-utils,
  prettytable,
  requests,
  setuptools,
  webob,
}:

buildPythonPackage rec {
  pname = "osprofiler";
  version = "4.3.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-d6jaKyO7X5BIBUvVzMRdCshFdMqKiO8SC4+sbohk4kw=";
  };

  # NOTE(vinetos): OSProfiler depends on jeager-client which use opentracing
  # Opentracing and jeager-client are archived since 2022.
  # As this package is made only to support old OpenStack clients and bindings,
  # We do not really care
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    netaddr
    oslo-concurrency
    oslo-config
    oslo-serialization
    oslo-utils
    prettytable
    requests
    webob
  ];

  pyproject = true;
  pythonImportsCheck = [ "osprofiler" ];

  meta = {
    description = "OpenStack Library to profile request between all involved services";
    homepage = "https://opendev.org/openstack/osprofiler/";
    license = lib.licenses.asl20;
    mainProgram = "osprofiler";
    teams = [ lib.teams.openstack ];
  };
}
