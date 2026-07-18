{
  buildPythonPackage,
  doc8,
  docutils,
  hacking,
  oslotest,
  pygments,
  python-octaviaclient,
  python-openstackclient,
  python-subunit,
  requests-mock,
  stestr,
  testscenarios,
}:

buildPythonPackage {
  inherit (python-octaviaclient) version src;
  pname = "python-octaviaclient-tests";

  nativeCheckInputs = [
    python-octaviaclient
    python-openstackclient
    hacking
    requests-mock
    doc8
    docutils
    pygments
    python-subunit
    oslotest
    stestr
    testscenarios
  ];

  checkPhase = ''
    runHook preCheck

    stestr run

    runHook postCheck
  '';

  dontBuild = true;
  dontInstall = true;
  pyproject = false;
}
