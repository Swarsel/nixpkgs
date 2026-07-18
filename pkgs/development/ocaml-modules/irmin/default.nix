{
  alcotest,
  astring,
  bheap,
  buildDunePackage,
  digestif,
  fmt,
  hex,
  jsonm,
  logs,
  lwt,
  mtime,
  ocamlgraph,
  optint,
  ppx_irmin,
  qcheck-alcotest,
  repr,
  uri,
  uutf,
  vector,
}:

buildDunePackage {
  inherit (ppx_irmin) src version;
  pname = "irmin";

  propagatedBuildInputs = [
    astring
    bheap
    digestif
    fmt
    jsonm
    logs
    lwt
    mtime
    ocamlgraph
    optint
    ppx_irmin
    repr
    uri
    uutf
  ];

  doCheck = true;

  checkInputs = [
    vector
    hex
    alcotest
    qcheck-alcotest
  ];

  minimalOCamlVersion = "4.10";

  meta = ppx_irmin.meta // {
    description = "Distributed database built on the same principles as Git";
  };
}
