{
  lib,
  buildPythonPackage,
  fetchPypi,
  # dependencies
  packaging,
  requests,
  # build-system
  setuptools,
  setuptools-scm,
  urllib3,
}:

buildPythonPackage rec {
  pname = "qbittorrent-api";
  version = "2026.7.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-nwpuM+5NuikNFV3jrVnBkd4C5NljnUJL8C7EoA7PMgU=";
    pname = "qbittorrent_api";
  };

  # Tests require internet access
  doCheck = false;

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    packaging
    requests
    urllib3
  ];

  pyproject = true;
  pythonImportsCheck = [ "qbittorrentapi" ];

  meta = {
    description = "Python client implementation for qBittorrent's Web API";
    homepage = "https://github.com/rmartin16/qbittorrent-api";
    changelog = "https://github.com/rmartin16/qbittorrent-api/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ savyajha ];
  };
}
