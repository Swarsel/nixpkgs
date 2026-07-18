{
  lib,
  fetchFromGitLab,
  buildDunePackage,
  readline,
}:

buildDunePackage {
  pname = "readline";
  version = "0.2";

  src = fetchFromGitLab {
    owner = "acg";
    repo = "dev/readline-ocaml";
    tag = "v0.2";
    hash = "sha256-qWxciodgINCFCxAVLdoU4z+ypWPYjrUwq8pU80saclw=";
    domain = "gitlab.inria.fr";
  };

  patches = [ ./dune.patch ];
  propagatedBuildInputs = [ readline ];

  preConfigure = ''
    echo "(${lib.getOutput "dev" readline}/include)" > src/iflags.sexp
    echo "(-L${lib.getOutput "lib" readline}/lib -lreadline)" > src/lflags.sexp
  '';

  minimalOCamlVersion = "4.14";

  meta = {
    description = "OCaml bindings for GNU Readline";
    homepage = "https://acg.gitlabpages.inria.fr/dev/readline-ocaml/readline/index.html";
    license = lib.licenses.cecill20;
    maintainers = [ lib.maintainers.tournev ];
  };
}
