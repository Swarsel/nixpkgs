{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  requests,
  setuptools,
}:

buildPythonPackage rec {
  pname = "nextcloudmonitor";
  version = "1.6.0";

  src = fetchFromGitHub {
    owner = "meichthys";
    repo = "nextcloud_monitor";
    tag = "v${version}";
    hash = "sha256-748cDMxPjOQFKdSt1GrQqZHmPgz20HN1+lMzo2vMj6c=";
  };

  # no tests implemented
  doCheck = false;
  build-system = [ setuptools ];
  dependencies = [ requests ];
  pyproject = true;
  pythonImportsCheck = [ "nextcloudmonitor" ];

  meta = {
    description = "Python wrapper around nextcloud monitor api";
    homepage = "https://github.com/meichthys/nextcloud_monitor";
    changelog = "https://github.com/meichthys/nextcloud_monitor/blob/${src.tag}/README.md#change-log";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
