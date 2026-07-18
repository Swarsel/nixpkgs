{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  networkx,
  numpy,
  pytestCheckHook,
  scipy,
  six,
}:

buildPythonPackage rec {
  pname = "geometric";
  version = "1.1.1";

  src = fetchFromGitHub {
    owner = "leeping";
    repo = "geomeTRIC";
    tag = version;
    hash = "sha256-LY5eNKocJL/Ty8tLup6q2o5RkGfIp6P6Hmju4wF3cDw=";
  };

  propagatedBuildInputs = [
    networkx
    numpy
    scipy
    six
  ];

  nativeCheckInputs = [ pytestCheckHook ];
  format = "setuptools";

  meta = {
    description = "Geometry optimization code for molecular structures";
    homepage = "https://github.com/leeping/geomeTRIC";
    license = [ lib.licenses.bsd3 ];
    maintainers = [ lib.maintainers.markuskowa ];
    mainProgram = "geometric-optimize";
  };
}
