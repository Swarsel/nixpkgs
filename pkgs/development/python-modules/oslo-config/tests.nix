{
  buildPythonPackage,
  docutils,
  oslo-config,
  oslo-log,
  oslotest,
  requests-mock,
  sphinx,
  stestr,
  testscenarios,
}:

buildPythonPackage {
  inherit (oslo-config) version src;
  pname = "oslo-config-tests";

  postPatch = ''
    # only a small portion of the listed packages are actually needed for running the tests
    # so instead of removing them one by one remove everything
    rm test-requirements.txt
  '';

  nativeCheckInputs = [
    oslo-config
    docutils
    oslo-log
    oslotest
    requests-mock
    sphinx
    stestr
    testscenarios
  ];

  checkPhase = ''
    stestr run
  '';

  dontBuild = true;
  dontInstall = true;
  pyproject = false;
}
