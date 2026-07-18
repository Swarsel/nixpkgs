{
  lib,
  fetchPypi,
  python3Packages,
}:
python3Packages.buildPythonApplication (finalAttrs: {
  pname = "catt";
  version = "0.13.1";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-hlCB06l4nzafvcnBNCXWiJsJNmP8n731bQgq5xvUZvM=";
  };

  doCheck = false; # attempts to access various URLs

  build-system = [
    python3Packages.poetry-core
  ];

  dependencies = [
    python3Packages.click
    python3Packages.ifaddr
    python3Packages.pychromecast
    python3Packages.requests
    python3Packages.yt-dlp
  ];

  pyproject = true;

  pythonImportsCheck = [
    "catt"
  ];

  meta = {
    description = "Send media from online sources to Chromecast devices";
    homepage = "https://github.com/skorokithakis/catt";
    changelog = "https://github.com/skorokithakis/catt/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.bsd2;
    maintainers = [ ];
    mainProgram = "catt";
  };
})
