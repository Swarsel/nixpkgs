{
  lib,
  fetchurl,
  buildDunePackage,
}:

buildDunePackage rec {
  pname = "trace";
  version = "0.5";

  src = fetchurl {
    url = "https://github.com/c-cube/ocaml-trace/releases/download/v${version}/trace-${version}.tbz";
    hash = "sha256-l0NvWPGBd1WR+b50WXEYfptuCUjda8MlZ/o5YngRNIg=";
  };

  minimalOCamlVersion = "4.07";

  meta = {
    description = "Common interface for tracing/instrumentation libraries in OCaml";
    homepage = "https://c-cube.github.io/ocaml-trace/";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.vbgl ];
  };

}
