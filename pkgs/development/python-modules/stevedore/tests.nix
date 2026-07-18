{
  buildPythonPackage,
  sphinx,
  stestr,
  stevedore,
}:

buildPythonPackage {
  inherit (stevedore) version src;
  pname = "stevedore-tests";

  nativeCheckInputs = [
    sphinx
    stestr
    stevedore
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
