{
  buildPythonPackage,
  debtcollector,
  stestr,
}:

buildPythonPackage {
  inherit (debtcollector) version src;
  pname = "debtcollector-tests";

  postPatch = ''
    # only a small portion of the listed packages are actually needed for running the tests
    # so instead of removing them one by one remove everything
    rm test-requirements.txt
  '';

  nativeCheckInputs = [
    debtcollector
    stestr
  ];

  checkPhase = ''
    stestr run
  '';

  dontBuild = true;
  dontInstall = true;
  pyproject = false;
}
