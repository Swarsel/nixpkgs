{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  hatchling,
}:

buildPythonPackage rec {
  pname = "aiomusiccast";
  version = "0.15.0";

  src = fetchFromGitHub {
    owner = "vigonotion";
    repo = "aiomusiccast";
    tag = version;
    hash = "sha256-oFA8i/cdDqOQ9Fq0VWd8eiOg8F1+MNxWanNqoao5+pM=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace '"0.0.0"' '"${version}"'
  '';

  # upstream has no tests
  doCheck = false;
  build-system = [ hatchling ];

  dependencies = [
    aiohttp
  ];

  pyproject = true;
  pythonImportsCheck = [ "aiomusiccast" ];

  meta = {
    description = "Companion library for musiccast devices intended for the Home Assistant integration";
    homepage = "https://github.com/vigonotion/aiomusiccast";
    changelog = "https://github.com/vigonotion/aiomusiccast/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
