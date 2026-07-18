{
  mkPythonMetaPackage,
  opencv4,
}:

mkPythonMetaPackage {
  inherit (opencv4) version;
  pname = "opencv-contrib-python";
  dependencies = [ opencv4 ];
  optional-dependencies = opencv4.optional-dependencies or { };

  meta = {
    inherit (opencv4.meta) description homepage;
  };
}
