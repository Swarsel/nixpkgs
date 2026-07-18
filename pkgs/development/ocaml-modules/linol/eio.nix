{
  buildDunePackage,
  eio,
  linol,
}:

buildDunePackage {
  inherit (linol) version src;
  pname = "linol-eio";

  propagatedBuildInputs = [
    eio
    linol
  ];

  meta = linol.meta // {
    description = "LSP server library (with Eio for concurrency)";
  };
}
