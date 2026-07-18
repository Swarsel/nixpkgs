{
  lib,
  fetchurl,
  buildDunePackage,
  dyn,
  ppx_expect,
  stdune,
}:

buildDunePackage (finalAttrs: {
  pname = "fiber";
  version = "3.7.0";

  src = fetchurl {
    url = "https://github.com/ocaml-dune/fiber/releases/download/${finalAttrs.version}/fiber-lwt-${finalAttrs.version}.tbz";
    hash = "sha256-hkihWuk/5pQpmc42iHQpo5E7YoKcRxTlIMwOehw7loI=";
  };

  buildInputs = [
    stdune
    dyn
  ];

  # Tests are Ocaml version dependent
  # https://github.com/ocaml-dune/fiber/issues/27
  doCheck = false;
  checkInputs = [ ppx_expect ];

  meta = {
    description = "Structured concurrency library";
    homepage = "https://github.com/ocaml-dune/fiber";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
})
