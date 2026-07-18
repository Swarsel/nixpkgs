{
  lib,
  buildPythonPackage,
  fetchPypi,
  packaging,
  python-socketio,
}:

buildPythonPackage rec {
  pname = "uptime-kuma-api";
  version = "1.2.1";

  src = fetchPypi {
    inherit version;
    hash = "sha256-tZ5ln3sy6W5RLcwjzLbhobCNLbHXIhXIzrcOVCG+Z+E=";
    pname = "uptime_kuma_api";
  };

  propagatedBuildInputs = [
    packaging
    python-socketio
  ]
  ++ python-socketio.optional-dependencies.client;

  # Tests need an uptime-kuma instance to run
  doCheck = false;
  format = "setuptools";
  pythonImportsCheck = [ "uptime_kuma_api" ];

  meta = {
    description = "Python wrapper for the Uptime Kuma Socket.IO API";
    homepage = "https://github.com/lucasheld/uptime-kuma-api";
    changelog = "https://github.com/lucasheld/uptime-kuma-api/blob/${version}/CHANGELOG.md";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ julienmalka ];
  };
}
