{
  lib,
  base64,
  buildDunePackage,
  cmdliner,
  opam,
  opam-repository,
  opam-solver,
  opam-state,
  re,
}:

buildDunePackage {
  inherit (opam) src version;
  pname = "opam-client";

  propagatedBuildInputs = [
    base64
    cmdliner
    opam-repository
    opam-solver
    opam-state
    re
  ];

  configureFlags = [ "--disable-checks" ];

  meta = opam.meta // {
    description = "Actions on the opam root, switches, installations, and front-end";
    maintainers = with lib.maintainers; [ stepbrobd ];
  };
}
