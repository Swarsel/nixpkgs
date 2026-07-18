{
  mkPythonMetaPackage,
  suds,
}:

mkPythonMetaPackage {
  inherit (suds) version;
  pname = "suds-community";
  dependencies = [ suds ];
  optional-dependencies = suds.optional-dependencies or { };

  meta = {
    inherit (suds.meta) changelog description homepage;
  };
}
