{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  hatchling,
}:

buildPythonPackage rec {
  pname = "pybravia";
  version = "0.4.1";

  src = fetchFromGitHub {
    owner = "Drafteed";
    repo = "pybravia";
    tag = "v${version}";
    hash = "sha256-VNdjdNmWcl8s1jRlA40DHlku3CPL59nJ4pZklZ452FU=";
  };

  # Module has no tests
  doCheck = false;
  build-system = [ hatchling ];
  dependencies = [ aiohttp ];
  pyproject = true;
  pythonImportsCheck = [ "pybravia" ];

  meta = {
    description = "Library for remote control of Sony Bravia TVs 2013 and newer";
    homepage = "https://github.com/Drafteed/pybravia";
    changelog = "https://github.com/Drafteed/pybravia/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
