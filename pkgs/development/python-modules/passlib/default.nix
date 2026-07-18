{
  libpass,
  mkPythonMetaPackage,
}:

mkPythonMetaPackage {
  inherit (libpass) version;
  pname = "passlib";
  dependencies = [ libpass ];
  optional-dependencies = libpass.optional-dependencies or { };

  meta = {
    inherit (libpass.meta) changelog description homepage;
  };
}
