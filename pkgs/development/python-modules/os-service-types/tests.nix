{
  buildPythonPackage,
  keystoneauth1,
  os-service-types,
  oslotest,
  requests-mock,
  stestr,
  testscenarios,
}:

buildPythonPackage {
  inherit (os-service-types) version src;
  pname = "os-service-types-tests";

  postPatch = ''
    # only a small portion of the listed packages are actually needed for running the tests
    # so instead of removing them one by one remove everything
    rm test-requirements.txt
  '';

  nativeCheckInputs = [
    os-service-types
    keystoneauth1
    oslotest
    requests-mock
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
