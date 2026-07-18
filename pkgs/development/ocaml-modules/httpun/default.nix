{
  alcotest,
  angstrom,
  bigstringaf,
  buildDunePackage,
  faraday,
  httpun-types,
}:

buildDunePackage {
  inherit (httpun-types) src version;
  pname = "httpun";

  propagatedBuildInputs = [
    angstrom
    bigstringaf
    faraday
    httpun-types
  ];

  doCheck = true;
  checkInputs = [ alcotest ];

  meta = httpun-types.meta // {
    description = "High-performance, memory-efficient, and scalable HTTP library for OCaml";
  };
}
