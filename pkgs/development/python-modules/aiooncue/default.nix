{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  setuptools,
}:

buildPythonPackage rec {
  pname = "aiooncue";
  version = "0.3.9";

  src = fetchFromGitHub {
    owner = "bdraco";
    repo = "aiooncue";
    tag = version;
    hash = "sha256-0Cdt/rUsl4OMLUTSC8WJXEiwzrhyn7JJIcVE/55LlgU=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace '"setuptools>=75.8.0"' ""
  '';

  # Tests are out-dated
  doCheck = false;
  build-system = [ setuptools ];
  dependencies = [ aiohttp ];
  pyproject = true;
  pythonImportsCheck = [ "aiooncue" ];

  meta = {
    description = "Module to interact with the Kohler Oncue API";
    homepage = "https://github.com/bdraco/aiooncue";
    changelog = "https://github.com/bdraco/aiooncue/releases/tag/${version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
}
