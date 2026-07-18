{
  lib,
  fetchPypi,
  python3Packages,
  versionCheckHook,
}:

python3Packages.buildPythonApplication rec {
  pname = "bashate";
  version = "2.1.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-S6tul3+DBacgU1+Pk/H7QsUh/LxKbCs9PXZx9C8iH0w=";
  };

  nativeCheckInputs = with python3Packages; [
    fixtures
    mock
    stestr
    testtools
  ];

  checkPhase = ''
    runHook preCheck
    stestr run
    runHook postCheck
  '';

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    babel
    pbr
  ];

  pyproject = true;
  pythonImportsCheck = [ "bashate" ];

  meta = {
    description = "Style enforcement for bash programs";
    homepage = "https://opendev.org/openstack/bashate";
    license = with lib.licenses; [ asl20 ];
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "bashate";
    teams = [ lib.teams.openstack ];
  };
}
