{
  lib,
  stdenv,
  fetchFromGitHub,
  findlib,
  ocaml,
  version ? if lib.versionAtLeast ocaml.version "4.08" then "0.16.1" else "0.14.3",
}:

stdenv.mkDerivation (finalAttrs: {
  inherit version;
  pname = "ocaml${ocaml.version}-ocamlbuild";

  src = fetchFromGitHub {
    owner = "ocaml";
    repo = "ocamlbuild";
    rev = finalAttrs.version;

    hash =
      {
        "0.14.3" = "sha256-dfcNu4ugOYu/M0rRQla7lXum/g1UzncdLGmpPYo0QUM=";
        "0.16.1" = "sha256-RpHVX0o4QduN73j+omlZlycRJaGZWfwHO5kq/WsEGZE=";
      }
      ."${finalAttrs.version}";
  };

  strictDeps = true;

  nativeBuildInputs = [
    ocaml
    findlib
  ];

  configurePhase = ''
    runHook preConfigure

    make -f configure.make Makefile.config \
      "OCAMLBUILD_PREFIX=$out" \
      "OCAMLBUILD_BINDIR=$out/bin" \
      "OCAMLBUILD_MANDIR=$out/share/man" \
      "OCAMLBUILD_LIBDIR=$OCAMLFIND_DESTDIR"

    runHook postConfigure
  '';

  createFindlibDestdir = true;

  meta = {
    inherit (ocaml.meta) platforms;
    description = "Build system with builtin rules to easily build most OCaml projects";
    homepage = "https://github.com/ocaml/ocamlbuild/";
    license = lib.licenses.lgpl2;
    maintainers = with lib.maintainers; [ vbgl ];
    mainProgram = "ocamlbuild";
  };
})
