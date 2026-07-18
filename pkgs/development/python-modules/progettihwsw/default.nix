{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  lxml,
  setuptools,
}:

buildPythonPackage rec {
  pname = "progettihwsw";
  version = "0.1.3";

  src = fetchFromGitHub {
    owner = "ardaseremet";
    repo = "progettihwsw";
    tag = version;
    hash = "sha256-9dpZyQ7i3WNdDVyEBLz4bJcWF1Ap7SH089PXWYI6UOA=";
  };

  # Package has no tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    lxml
  ];

  pyproject = true;
  pythonImportsCheck = [ "ProgettiHWSW" ];

  meta = {
    description = "Controls ProgettiHWSW relay boards";
    homepage = "https://github.com/ardaseremet/progettihwsw";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.jamiemagee ];
  };
}
