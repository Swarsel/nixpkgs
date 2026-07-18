{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  requests,
  setuptools,
  vcrpy,
}:

buildPythonPackage rec {
  pname = "libpyvivotek";
  version = "0.6.1";

  src = fetchFromGitHub {
    owner = "HarlemSquirrel";
    repo = "python-vivotek";
    tag = "v${version}";
    hash = "sha256-ai+FlvyrdeLyg/PJU8T0fTtbdnlyGo6mE4AM2oRATj8=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    vcrpy
  ];

  build-system = [ setuptools ];
  dependencies = [ requests ];
  pyproject = true;
  pythonImportsCheck = [ "libpyvivotek" ];

  meta = {
    description = "Python Library for Vivotek IP Cameras";
    homepage = "https://github.com/HarlemSquirrel/python-vivotek";
    changelog = "https://github.com/HarlemSquirrel/python-vivotek/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
}
