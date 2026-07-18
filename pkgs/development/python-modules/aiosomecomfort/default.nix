{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  prettytable,
  setuptools,
}:

buildPythonPackage rec {
  pname = "aiosomecomfort";
  version = "0.0.37";

  src = fetchFromGitHub {
    owner = "mkmer";
    repo = "AIOSomecomfort";
    tag = version;
    hash = "sha256-xyGJsSgxE/UwTEfA2BzVHvgqG1c47/SokLHrysPkFAU=";
  };

  # Tests only run on Windows, due to WindowsSelectorEventLoopPolicy
  doCheck = false;

  build-system = [
    setuptools
  ];

  dependencies = [
    aiohttp
    prettytable
  ];

  pyproject = true;
  pythonImportsCheck = [ "aiosomecomfort" ];

  pythonRelaxDeps = [
    "aiohttp"
  ];

  meta = {
    description = "AsyicIO client for US models of Honeywell Thermostats";
    homepage = "https://github.com/mkmer/AIOSomecomfort";
    changelog = "https://github.com/mkmer/AIOSomecomfort/releases/tag/${version}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
