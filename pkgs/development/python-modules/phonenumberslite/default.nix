{
  mkPythonMetaPackage,
  phonenumbers,
}:

mkPythonMetaPackage {
  inherit (phonenumbers) version;
  pname = "phonenumberslite";
  dependencies = [ phonenumbers ];
  optional-dependencies = phonenumbers.optional-dependencies or { };

  meta = {
    inherit (phonenumbers.meta) changelog description homepage;
  };
}
