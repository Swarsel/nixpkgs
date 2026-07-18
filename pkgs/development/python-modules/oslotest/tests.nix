{
  buildPythonPackage,
  oslo-config,
  oslotest,
  stestr,
}:

buildPythonPackage {
  inherit (oslotest) version src;
  pname = "oslotest-tests";

  postPatch = ''
    # only a small portion of the listed packages are actually needed for running the tests
    # so instead of removing them one by one remove everything
    rm test-requirements.txt
  '';

  nativeCheckInputs = [
    oslotest
    oslo-config
    stestr
  ];

  checkPhase = ''
    stestr run
  '';

  dontBuild = true;
  dontInstall = true;
  pyproject = false;
}
