{
  lib,
  fetchurl,
  buildDunePackage,
  cppo,
  dune-configurator,
  ppx_deriving,
  ppxlib,
}:

buildDunePackage (finalAttrs: {
  pname = "ppx_deriving_protobuf";
  version = "3.0.0";

  src = fetchurl {
    url = "https://github.com/ocaml-ppx/ppx_deriving_protobuf/releases/download/v${finalAttrs.version}/ppx_deriving_protobuf-v${finalAttrs.version}.tbz";
    sha256 = "1dc1vxnkd0cnrgac5v3zbaj2lq1d2w8118mp1cmsdxylp06yz1sj";
  };

  nativeBuildInputs = [ cppo ];

  buildInputs = [
    ppxlib
    dune-configurator
  ];

  propagatedBuildInputs = [ ppx_deriving ];
  duneVersion = "3";

  meta = {
    description = "Protocol Buffers codec generator for OCaml";
    homepage = "https://github.com/ocaml-ppx/ppx_deriving_protobuf";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.vyorkin ];
  };
})
