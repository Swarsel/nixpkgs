{
  buildPythonPackage,
  cliff,
  sphinx,
  stestr,
  testscenarios,
}:

buildPythonPackage {
  inherit (cliff) version src;
  pname = "cliff";

  postPatch = ''
    # only a small portion of the listed packages are actually needed for running the tests
    # so instead of removing them one by one remove everything
    rm test-requirements.txt
  '';

  nativeCheckInputs = [
    cliff
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
