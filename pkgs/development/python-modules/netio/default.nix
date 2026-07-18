{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  poetry-core,
  pyopenssl,
  requests,
}:

buildPythonPackage rec {
  pname = "netio";
  version = "1.0.13";

  src = fetchFromGitHub {
    owner = "netioproducts";
    repo = "PyNetio";
    tag = "v${version}";
    hash = "sha256-s/X2WGhQXYsbo+ZPpkVSF/vclaThYYNHu0UY0yCnfPA=";
  };

  nativeBuildInputs = [
    poetry-core
  ];

  propagatedBuildInputs = [
    requests
    pyopenssl
  ];

  # Module has no tests
  doCheck = false;
  pyproject = true;
  pythonImportsCheck = [ "Netio" ];
  pythonRelaxDeps = [ "pyopenssl" ];

  meta = {
    description = "Module for interacting with NETIO devices";
    homepage = "https://github.com/netioproducts/PyNetio";
    changelog = "https://github.com/netioproducts/PyNetio/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "Netio";
  };
}
