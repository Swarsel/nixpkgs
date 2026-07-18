{
  lib,
  buildPythonPackage,
  fetchPypi,
  fixtures,
  pbr,
  prettytable,
  python-ldap,
  setuptools,
  six,
  testresources,
  testtools,
  unittestCheckHook,
}:

buildPythonPackage rec {
  pname = "ldappool";
  version = "3.0.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-S7WbfWsRQH9I7gGngSZ+PIupjZH0JoBqxyCGEq4Ie4Y=";
    pname = "ldappool";
  };

  nativeCheckInputs = [
    unittestCheckHook
    fixtures
    testresources
    testtools
  ];

  build-system = [
    setuptools
    pbr
  ];

  dependencies = [
    python-ldap
    prettytable
    six
  ];

  pyproject = true;
  pythonImportsCheck = [ "ldappool" ];

  meta = {
    description = "Simple connector pool for python-ldap";
    homepage = "https://opendev.org/openstack/ldappool/";

    license = with lib.licenses; [
      mpl11
      lgpl21Plus
      gpl2Plus
    ];
  };
}
