{
  lib,
  buildPythonPackage,
  immutabledict,
  lndir,
  numpy,
  or-tools,
  pandas,
  protobuf,
}:

buildPythonPackage {
  inherit (or-tools) version;
  pname = "ortools";
  src = or-tools.python;
  nativeBuildInputs = [ lndir ];

  propagatedBuildInputs = [
    immutabledict
    numpy
    pandas
    protobuf
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    lndir -silent $src $out
    runHook postInstall
  '';

  dontBuild = true;
  format = "other";

  pythonImportsCheck = [
    "ortools"
    "ortools.sat.python.cp_model"
  ];

  meta = or-tools.meta // {
    description = "Python bindings for Google's or-tools";
  };
}
