{
  lib,
  bigstringaf,
  buildDunePackage,
  either,
  ezjsonm,
  hex,
  json-data-encoding,
  json-data-encoding-bson,
  ppx_expect,
  ppx_hash,
  zarith,
  zarith_stubs_js ? null,
}:

buildDunePackage {
  inherit (json-data-encoding) src version;
  pname = "data-encoding";

  buildInputs = [
    ppx_expect
  ];

  propagatedBuildInputs = [
    bigstringaf
    either
    ezjsonm
    ppx_hash
    zarith
    zarith_stubs_js
    hex
    json-data-encoding
    json-data-encoding-bson
  ];

  minimalOCamlVersion = "4.10";

  meta = {
    description = "Library of JSON and binary encoding combinators";
    homepage = "https://gitlab.com/nomadic-labs/data-encoding";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.ulrikstrid ];
  };
}
