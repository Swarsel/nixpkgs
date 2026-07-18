{
  lib,
  buildDunePackage,
  opam-core,
  opam-file-format,
}:

buildDunePackage {
  inherit (opam-core) src version;
  pname = "opam-format";

  propagatedBuildInputs = [
    opam-core
    opam-file-format
  ];

  # get rid of check for curl at configure time
  # opam-format does not call curl at run time
  configureFlags = [ "--disable-checks" ];

  meta = opam-core.meta // {
    description = "Definition of opam datastructures and its file interface";
    maintainers = with lib.maintainers; [ sternenseemann ];
  };
}
