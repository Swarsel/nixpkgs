{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  paramiko,
  setuptools,
}:

buildPythonPackage rec {
  pname = "unifi-ap";
  version = "0.0.2";

  src = fetchFromGitHub {
    owner = "tofuSCHNITZEL";
    repo = "unifi_ap";
    tag = "v${version}";
    hash = "sha256-LQqeXFtrOc1h3yJuDrFRt3mqVcDIJb/23rcu/l6YpUQ=";
  };

  doCheck = false; # no tests

  build-system = [
    setuptools
  ];

  dependencies = [
    paramiko
  ];

  pyproject = true;

  pythonImportsCheck = [
    "unifi_ap"
  ];

  pythonRelaxDeps = [ "paramiko" ];

  meta = {
    description = "Python API for UniFi accesspoints";
    homepage = "https://github.com/tofuSCHNITZEL/unifi_ap";
    changelog = "https://github.com/tofuSCHNITZEL/unifi_ap/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
