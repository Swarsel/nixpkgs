{
  buildDunePackage,
  mtime,
  trace,
}:

buildDunePackage {
  inherit (trace) src version;
  pname = "trace-tef";

  # This removes the dependency on the “atomic” package
  # (not available in nixpkgs)
  # Said package for OCaml ≥ 4.12 is empty
  postPatch = ''
    substituteInPlace src/tef/dune --replace 'atomic ' ""
  '';

  propagatedBuildInputs = [
    mtime
    trace
  ];

  doCheck = true;
  minimalOCamlVersion = "4.12";

  meta = trace.meta // {
    description = "Simple backend for trace, emitting Catapult JSON into a file";
  };

}
