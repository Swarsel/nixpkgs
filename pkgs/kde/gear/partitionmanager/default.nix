{
  kpmcore,
  mkKdeDerivation,
}:
mkKdeDerivation {
  pname = "partitionmanager";
  propagatedUserEnvPkgs = [ kpmcore ];

  passthru = {
    inherit kpmcore;
  };

  meta.mainProgram = "partitionmanager";
}
