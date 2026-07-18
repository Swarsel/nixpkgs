{
  lib,
  fetchFromGitHub,
  buildDunePackage,
  gnuplot,
  iso8601,
}:

buildDunePackage (finalAttrs: {
  pname = "gnuplot";
  version = "0.7";

  src = fetchFromGitHub {
    owner = "c-cube";
    repo = "ocaml-gnuplot";
    tag = "v${finalAttrs.version}";
    hash = "sha256-CTIjZbDM6LX6/dR6hF9f8ipb99CDHLV0y9qfsuiI/wo=";
  };

  propagatedBuildInputs = [
    gnuplot
    iso8601
  ];

  meta = {
    description = "OCaml bindings to Gnuplot";
    homepage = "https://github.com/c-cube/ocaml-gnuplot";
    license = lib.licenses.lgpl21;
    maintainers = [ lib.maintainers.bcdarwin ];
  };
})
