{
  buildDunePackage,
  pgocaml,
  ppx_optcomp,
}:

buildDunePackage {
  inherit (pgocaml) src version meta;
  pname = "pgocaml_ppx";
  buildInputs = [ ppx_optcomp ];
  propagatedBuildInputs = [ pgocaml ];
}
