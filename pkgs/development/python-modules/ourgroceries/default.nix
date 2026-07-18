{
  lib,
  fetchFromGitHub,
  aiohttp,
  beautifulsoup4,
  buildPythonPackage,
  setuptools,
}:

buildPythonPackage rec {
  pname = "ourgroceries";
  version = "1.5.4";

  src = fetchFromGitHub {
    owner = "ljmerza";
    repo = "py-our-groceries";
    tag = version;
    hash = "sha256-tlgctQvbR2YzM6Q1A/P1i40LSt4/2hsetlDeO07RBPE=";
  };

  # tests require credentials
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    beautifulsoup4
  ];

  pyproject = true;
  pythonImportsCheck = [ "ourgroceries" ];

  meta = {
    description = "Unofficial Python Wrapper for Our Groceries";
    homepage = "https://github.com/ljmerza/py-our-groceries";
    changelog = "https://github.com/ljmerza/py-our-groceries/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
