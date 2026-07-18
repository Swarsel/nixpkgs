{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  numpy,
  openssl,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "sipyco";
  version = "1.10";

  src = fetchFromGitHub {
    owner = "m-labs";
    repo = "sipyco";
    tag = "v${version}";
    hash = "sha256-DkcgZ0K6lsxzBWc31GTyufuSOpcorVv5OsZLHphHBtg=";
  };

  nativeCheckInputs = [
    openssl
    pytestCheckHook
  ];

  __darwinAllowLocalNetworking = true;
  build-system = [ setuptools ];
  dependencies = [ numpy ];
  pyproject = true;
  pythonImportsCheck = [ "sipyco" ];

  meta = {
    description = "Simple Python Communications - used by the ARTIQ experimental control package";
    homepage = "https://github.com/m-labs/sipyco";
    changelog = "https://github.com/m-labs/sipyco/releases/tag/${src.tag}";
    license = lib.licenses.lgpl3Plus;
    maintainers = with lib.maintainers; [ charlesbaynham ];
    mainProgram = "sipyco_rpctool";
  };
}
