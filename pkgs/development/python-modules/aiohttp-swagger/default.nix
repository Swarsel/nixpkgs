{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  jinja2,
  markupsafe,
  pyyaml,
  setuptools,
}:

buildPythonPackage rec {
  pname = "aiohttp-swagger";
  version = "1.0.15";

  src = fetchFromGitHub {
    owner = "cr0hn";
    repo = "aiohttp-swagger";
    tag = version;
    hash = "sha256-M43sNpbXWXFRTd549cZhvhO35nBB6OH+ki36BzSk87Q=";
  };

  build-system = [
    setuptools
  ];

  dependencies = [
    aiohttp
    jinja2
    markupsafe
    pyyaml
  ];

  pyproject = true;
  pythonImportsCheck = [ "aiohttp_swagger" ];

  pythonRelaxDeps = [
    "markupsafe"
    "jinja2"
  ];

  meta = {
    description = "Swagger API Documentation builder for aiohttp";
    homepage = "https://github.com/cr0hn/aiohttp-swagger";
    license = lib.licenses.mit;
  };
}
