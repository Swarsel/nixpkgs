{
  lib,
  buildPythonPackage,
  flatbuffers,
}:

buildPythonPackage rec {
  inherit (flatbuffers) pname version src;
  # flatbuffers needs VERSION environment variable for setting the correct
  # version, otherwise it uses the current date.
  env.VERSION = version;
  format = "setuptools";
  pythonImportsCheck = [ "flatbuffers" ];
  sourceRoot = "${src.name}/python";

  meta = flatbuffers.meta // {
    description = "Python runtime library for use with the Flatbuffers serialization format";
    maintainers = with lib.maintainers; [ wulfsta ];
    mainProgram = "flatc";
  };
}
