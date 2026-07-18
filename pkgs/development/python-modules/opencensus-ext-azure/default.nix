{
  lib,
  fetchFromGitHub,
  azure-core,
  azure-identity,
  buildPythonPackage,
  opencensus,
  psutil,
  requests,
  setuptools,
}:

buildPythonPackage rec {
  pname = "opencensus-ext-azure";
  version = "1.1.15";

  src = fetchFromGitHub {
    owner = "census-instrumentation";
    repo = "opencensus-python";
    tag = "opencensus-ext-azure@${version}";
    hash = "sha256-fnqflSyNnkEy9XYoirk4iDZI1zYTRMbrYMyQ/4ge3Rs=";
  };

  doCheck = false; # tests are not included in the PyPi tarball
  build-system = [ setuptools ];

  dependencies = [
    azure-core
    azure-identity
    opencensus
    psutil
    requests
  ];

  pyproject = true;
  pythonImportsCheck = [ "opencensus.ext.azure" ];
  sourceRoot = "${src.name}/contrib/opencensus-ext-azure";

  meta = {
    description = "OpenCensus Azure Monitor Exporter";
    homepage = "https://github.com/census-instrumentation/opencensus-python/tree/master/contrib/opencensus-ext-azure";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      billhuang
      evilmav
    ];
  };
}
