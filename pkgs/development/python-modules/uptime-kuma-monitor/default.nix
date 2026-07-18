{
  lib,
  buildPythonPackage,
  fetchPypi,
  prometheus-client,
  requests,
}:

buildPythonPackage rec {
  pname = "uptime-kuma-monitor";
  version = "1.0.0";

  src = fetchPypi {
    inherit version;
    sha256 = "0zi4856hj5ar4yidh7366kx3xnh8qzydw9z8vlalcn98jf3jlnk9";
    pname = "uptime_kuma_monitor";
  };

  propagatedBuildInputs = [
    requests
    prometheus-client
  ];

  # Project has no test
  doCheck = false;
  format = "setuptools";
  pythonImportsCheck = [ "uptime_kuma_monitor" ];

  meta = {
    description = "Python wrapper around UptimeKuma /metrics endpoint";
    homepage = "https://github.com/meichthys/utptime_kuma_monitor";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ fab ];
  };
}
