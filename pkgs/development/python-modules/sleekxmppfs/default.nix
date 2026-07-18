{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  dnspython,
  pyasn1,
  pyasn1-modules,
  setuptools,
}:

buildPythonPackage rec {
  pname = "sleekxmppfs";
  version = "1.4.1";

  src = fetchFromGitHub {
    owner = "aszymanik";
    repo = "SleekXMPP";
    tag = "sleek-${version}";
    hash = "sha256-E2S4fMk5dRr8g42iOYmKOknHX7NS6EZ/LAZKc1v3dPg=";
  };

  # tests weren't adapted for the fork
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    dnspython
    pyasn1
    pyasn1-modules
  ];

  pyproject = true;
  pythonImportsCheck = [ "sleekxmppfs" ];

  meta = {
    description = "Fork of SleekXMPP with TLS cert validation disabled, intended only to be used with the sucks project";
    homepage = "https://github.com/aszymanik/SleekXMPP";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
