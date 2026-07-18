{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  requests,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "growattserver";
  version = "2.2.0";

  src = fetchFromGitHub {
    owner = "indykoning";
    repo = "PyPi_GrowattServer";
    tag = finalAttrs.version;
    hash = "sha256-zVcKuwTxuCCIZzVKgEdjULSyKgKcb/Fb93rk3J8ztCg=";
  };

  # Project has no tests
  doCheck = false;
  build-system = [ setuptools ];
  dependencies = [ requests ];
  pyproject = true;
  pythonImportsCheck = [ "growattServer" ];

  meta = {
    description = "Python package to retrieve information from Growatt units";
    homepage = "https://github.com/indykoning/PyPi_GrowattServer";
    changelog = "https://github.com/indykoning/PyPi_GrowattServer/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
