{
  buildPythonPackage,
  ddt,
  fixtures,
  python-manilaclient,
  python-openstackclient,
  requests-mock,
  stestr,
  tempest,
  testtools,
}:

buildPythonPackage {
  inherit (python-manilaclient) version src;
  pname = "python-manilaclient-tests";

  nativeCheckInputs = [
    ddt
    fixtures
    python-manilaclient
    python-openstackclient
    requests-mock
    stestr
    tempest
    testtools
  ];

  checkPhase = ''
    stestr run
  '';

  dontBuild = true;
  dontInstall = true;
  pyproject = false;
}
