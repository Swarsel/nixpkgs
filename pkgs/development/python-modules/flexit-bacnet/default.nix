{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
}:

buildPythonPackage rec {
  pname = "flexit-bacnet";
  version = "2.2.3";

  src = fetchFromGitHub {
    owner = "piotrbulinski";
    repo = "flexit_bacnet";
    tag = version;
    hash = "sha256-MudBn+ki/jqeFK1iz/vAXaXkkddLThO+1T4BXFJ90lk=";
  };

  # upstream has no tests
  doCheck = false;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "flexit_bacnet" ];

  meta = {
    description = "Client BACnet library for Flexit Nordic series of air handling units";
    homepage = "https://github.com/piotrbulinski/flexit_bacnet";
    changelog = "https://github.com/piotrbulinski/flexit_bacnet/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
