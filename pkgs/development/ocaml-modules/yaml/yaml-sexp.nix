{
  buildDunePackage,
  junit_alcotest,
  ppx_sexp_conv,
  sexplib,
  yaml,
}:

buildDunePackage {
  inherit (yaml) version src;
  pname = "yaml-sexp";

  propagatedBuildInputs = [
    yaml
    ppx_sexp_conv
    sexplib
  ];

  doCheck = true;
  checkInputs = [ junit_alcotest ];

  meta = yaml.meta // {
    description = "ocaml-yaml with sexp support";
  };
}
