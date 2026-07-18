{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatch-requirements-txt,
  hatchling,
  mockupdb,
  pymongo,
}:

buildPythonPackage rec {
  pname = "motor";
  version = "3.7.1";

  src = fetchFromGitHub {
    owner = "mongodb";
    repo = "motor";
    tag = version;
    hash = "sha256-ul2GKzSiAewwGEuCpQQ61h3cqrJikaJeKs5KlX+aAjo=";
  };

  # network connections
  doCheck = false;
  nativeCheckInputs = [ mockupdb ];

  build-system = [
    hatchling
    hatch-requirements-txt
  ];

  dependencies = [ pymongo ];
  pyproject = true;
  pythonImportsCheck = [ "motor" ];
  pythonRelaxDeps = [ "pymongo" ];

  meta = {
    description = "Non-blocking MongoDB driver for Tornado or asyncio";
    homepage = "https://github.com/mongodb/motor";
    changelog = "https://github.com/mongodb/motor/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
}
