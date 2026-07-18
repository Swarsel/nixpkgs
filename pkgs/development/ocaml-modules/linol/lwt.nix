{
  buildDunePackage,
  linol,
  lwt,
}:

buildDunePackage {
  inherit (linol) version src;
  pname = "linol-lwt";

  propagatedBuildInputs = [
    linol
    lwt
  ];

  meta = linol.meta // {
    description = "LSP server library (with Lwt for concurrency)";
  };
}
