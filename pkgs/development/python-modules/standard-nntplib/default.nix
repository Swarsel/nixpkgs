{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  pythonOlder,
  setuptools,
}:

buildPythonPackage rec {
  pname = "standard-nntplib";
  version = "3.13.0";

  src = fetchFromGitHub {
    owner = "youknowone";
    repo = "python-deadlib";
    tag = "v${version}";
    hash = "sha256-J8c55f527QGcK8p/QKJBZeZV0y9DU0iM1RUFVkWh2Hc=";
    sparseCheckout = [ "nntplib" ];
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  disabled = pythonOlder "3.13";
  pyproject = true;
  pythonImportsCheck = [ "nntplib" ];
  sourceRoot = "${src.name}/nntplib";

  meta = {
    description = "Standard library nntplib redistribution";
    homepage = "https://github.com/youknowone/python-deadlib";
    license = lib.licenses.psfl;
    maintainers = [ lib.maintainers.qyliss ];
  };
}
