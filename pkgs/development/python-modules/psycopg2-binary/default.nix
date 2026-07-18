{
  mkPythonMetaPackage,
  psycopg2,
}:
mkPythonMetaPackage {
  inherit (psycopg2) version;
  pname = "psycopg2-binary";
  dependencies = [ psycopg2 ];
  optional-dependencies = psycopg2.optional-dependencies or { };

  meta = {
    inherit (psycopg2.meta) description homepage;
  };
}
