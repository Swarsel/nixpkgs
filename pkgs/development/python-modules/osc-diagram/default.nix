{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  diagrams,
  osc-sdk-python,
  setuptools,
}:

buildPythonPackage {
  pname = "osc-diagram";
  version = "unstable-2023-08-07";

  src = fetchFromGitHub {
    owner = "outscale-mgo";
    repo = "osc-diagram";
    rev = "8531233b8a95da03aca9106064b91479197f888d";
    hash = "sha256-2Iaar2twemw4xv1GGqHd3xiNCHrZLsZXtP7e9tNVpEU=";
  };

  nativeBuildInputs = [ setuptools ];

  propagatedBuildInputs = [
    diagrams
    osc-sdk-python
  ];

  pyproject = true;
  pythonImportsCheck = [ "osc_diagram" ];

  meta = {
    description = "Build Outscale cloud diagrams";
    homepage = "https://github.com/outscale-mgo/osc-diagram";
    license = lib.licenses.free;
    maintainers = with lib.maintainers; [ nicolas-goudry ];
    mainProgram = "osc-diagram";
  };
}
