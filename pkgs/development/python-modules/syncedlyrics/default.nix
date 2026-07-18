{
  lib,
  fetchFromGitHub,
  beautifulsoup4,
  buildPythonPackage,
  poetry-core,
  rapidfuzz,
  requests,
}:

buildPythonPackage rec {
  pname = "syncedlyrics";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "rtcq";
    repo = "syncedlyrics";
    tag = "v${version}";
    hash = "sha256-rKYze8Z7F6cEkpex6UCFUW9+mf2UWT+T86C5COhYQHY=";
  };

  # Tests require network access
  doCheck = false;

  build-system = [
    poetry-core
  ];

  dependencies = [
    requests
    rapidfuzz
    beautifulsoup4
  ];

  pyproject = true;
  pythonImportsCheck = [ "syncedlyrics" ];
  pythonRelaxDeps = [ "rapidfuzz" ];

  meta = {
    description = "Module to get LRC format (synchronized) lyrics";
    homepage = "https://github.com/rtcq/syncedlyrics";
    changelog = "https://github.com/rtcq/syncedlyrics/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "syncedlyrics";
  };
}
