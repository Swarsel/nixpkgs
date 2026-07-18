{
  alcotest,
  buildDunePackage,
  crowbar,
  json-data-encoding,
  ocplib-endian,
}:

buildDunePackage {
  inherit (json-data-encoding) version src doCheck;
  pname = "json-data-encoding-bson";

  propagatedBuildInputs = [
    json-data-encoding
    ocplib-endian
  ];

  checkInputs = [
    crowbar
    alcotest
  ];

  meta = json-data-encoding.meta // {
    description = "Type-safe encoding to and decoding from JSON (bson support)";
  };
}
