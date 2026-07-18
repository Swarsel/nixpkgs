{
  mkPythonMetaPackage,
  sqlcipher3,
}:
mkPythonMetaPackage {
  inherit (sqlcipher3) version;
  pname = "sqlcipher3-binary";
  dependencies = [ sqlcipher3 ];
  optional-dependencies = sqlcipher3.optional-dependencies or { };

  meta = {
    inherit (sqlcipher3.meta) description homepage license;
  };
}
