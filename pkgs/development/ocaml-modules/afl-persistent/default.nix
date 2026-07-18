{
  lib,
  stdenv,
  fetchFromGitHub,
  findlib,
  ocaml,
  opaline,
}:

stdenv.mkDerivation rec {
  pname = "afl-persistent";
  version = "1.3";

  src = fetchFromGitHub {
    owner = "stedolan";
    repo = "ocaml-${pname}";
    rev = "v${version}";
    sha256 = "06yyds2vcwlfr2nd3gvyrazlijjcrd1abnvkfpkaadgwdw3qam1i";
  };

  # don't run tests in buildPhase
  # don't overwrite test binary
  postPatch = ''
    sed -i 's/ && \.\/test$//' build.sh
    sed -i '/^ocamlopt.*test.ml -o test$/ s/$/2/' build.sh
    patchShebangs build.sh
  '';

  strictDeps = true;

  nativeBuildInputs = [
    ocaml
    findlib
  ];

  buildPhase = "./build.sh";
  doCheck = true;
  checkPhase = "./_build/test && ./_build/test2";

  installPhase = ''
    ${opaline}/bin/opaline -prefix $out -libdir $out/lib/ocaml/${ocaml.version}/site-lib/ ${pname}.install
  '';

  name = "ocaml${ocaml.version}-${pname}-${version}";

  meta = {
    description = "Persistent-mode afl-fuzz for ocaml";
    homepage = "https://github.com/stedolan/ocaml-afl-persistent";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sternenseemann ];
  };
}
