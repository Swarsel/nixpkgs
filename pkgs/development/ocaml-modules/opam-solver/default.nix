{
  lib,
  buildDunePackage,
  cudf,
  dose3,
  mccs,
  opam,
  opam-0install-cudf,
  opam-format,
  re,
  z3,
}:

buildDunePackage {
  inherit (opam) src version;
  pname = "opam-solver";

  propagatedBuildInputs = [
    cudf
    dose3
    mccs
    opam-0install-cudf
    opam-format
    re
    z3
  ];

  configureFlags = [ "--disable-checks" ];

  meta = opam.meta // {
    description = "This library is based on the Cudf and Dose libraries, and handles calls to the external solver from opam";
    maintainers = with lib.maintainers; [ stepbrobd ];
  };
}
