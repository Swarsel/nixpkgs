{
  alcotest,
  base64,
  buildDunePackage,
  camlp-streams,
  optint,
  seppo,
  uri,
}:

buildDunePackage {
  inherit (seppo) version src;
  pname = "mcdb";

  propagatedBuildInputs = [
    camlp-streams
    optint
  ];

  checkInputs = [
    alcotest
    uri
    base64
  ];
}
