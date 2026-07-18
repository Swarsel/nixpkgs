{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  setuptools,
  voluptuous,
}:
buildPythonPackage rec {
  pname = "alphaess";
  version = "0.0.19";

  src = fetchFromGitHub {
    owner = "CharlesGillanders";
    repo = "alphaess-openAPI";
    tag = version;
    sha256 = "sha256-wdwA1MIQrkZCT4zIf8WXyq0+F+peC/auVtjDJ8ZZyxE=";
  };

  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    voluptuous
  ];

  pyproject = true;

  pythonImportsCheck = [
    "alphaess"
  ];

  meta = {
    description = "Library that uses the Alpha ESS Open API to retrieve data on your Alpha ESS inverter, photovoltaic panels, and battery";
    homepage = "https://github.com/CharlesGillanders/alphaess-openAPI";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ benediktbroich ];
  };
}
