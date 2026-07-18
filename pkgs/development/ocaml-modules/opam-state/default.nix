{
  lib,
  buildDunePackage,
  opam,
  opam-repository,
  spdx_licenses,
}:

buildDunePackage {
  inherit (opam) src version;
  pname = "opam-state";

  propagatedBuildInputs = [
    opam-repository
    spdx_licenses
  ];

  # get rid of check for curl at configure time
  # opam-state does not call curl at run time
  configureFlags = [ "--disable-checks" ];

  meta = opam.meta // {
    description = "OPAM development library handling the ~/.opam hierarchy, repository and switch states";
    maintainers = with lib.maintainers; [ sternenseemann ];
  };
}
