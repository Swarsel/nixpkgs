{
  lib,
  beautifulsoup4,
  buildPythonPackage,
  fetchPypi,
  hatchling,
  pillow,
  requests,
  rich,
  uv-dynamic-versioning,
}:

buildPythonPackage (finalAttrs: {
  pname = "getjump";
  version = "2.10.0";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-AX8WffzcqBYqo8DzXXbhfqOMd7U5VpWx4MTKhUXLJeQ=";
  };

  # all the tests talk to the internet
  doCheck = false;

  build-system = [
    hatchling
    uv-dynamic-versioning
  ];

  dependencies = [
    beautifulsoup4
    pillow
    requests
    rich
  ];

  pyproject = true;
  pythonImportsCheck = [ "getjump" ];

  pythonRelaxDeps = [
    "pillow"
    "rich"
  ];

  meta = {
    description = "Get and save images from jump web viewer";
    homepage = "https://github.com/eggplants/getjump";
    changelog = "https://github.com/eggplants/getjump/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "jget";
  };
})
