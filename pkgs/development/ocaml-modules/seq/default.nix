{
  lib,
  stdenv,
  ocaml,
}:

stdenv.mkDerivation {
  pname = "ocaml${ocaml.version}-seq";
  version = "0.1";
  src = ./src-base;

  installPhase = ''
    mkdir -p $out/lib/ocaml/${ocaml.version}/site-lib/seq
    cp META $out/lib/ocaml/${ocaml.version}/site-lib/seq
  '';

  dontBuild = true;

  meta = {
    inherit (ocaml.meta) platforms;
    description = "Dummy backward-compatibility package for iterators";
    homepage = "https://github.com/c-cube/seq";
    license = lib.licenses.lgpl21;
    maintainers = [ lib.maintainers.vbgl ];
  };

}
