{
  lib,
  stdenv,
  cmake,
  ctypes,
  findlib,
  libllvm,
  ocaml,
  python3,
}:

let
  version = lib.getVersion libllvm;
in

stdenv.mkDerivation {
  inherit version;
  inherit (libllvm) src;
  pname = "ocaml-llvm";
  strictDeps = true;

  nativeBuildInputs = [
    cmake
    python3
    ocaml
    findlib
  ];

  buildInputs = [ ctypes ];
  propagatedBuildInputs = [ libllvm ];

  cmakeFlags = [
    "-DBUILD_SHARED_LIBS=YES" # fixes bytecode builds
    "-DLLVM_OCAML_OUT_OF_TREE=TRUE"
    "-DLLVM_OCAML_INSTALL_PATH=${placeholder "out"}/ocaml"
    "-DLLVM_OCAML_EXTERNAL_LLVM_LIBDIR=${lib.getLib libllvm}/lib"
  ];

  buildFlags = [ "ocaml_all" ];

  preConfigure = lib.optionalString (lib.versionAtLeast version "13.0.0") ''
    cd llvm
  '';

  postInstall = ''
    mkdir -p $OCAMLFIND_DESTDIR/
    mv $out/ocaml $OCAMLFIND_DESTDIR/llvm
    mv $OCAMLFIND_DESTDIR/llvm/META{.llvm,}
    mv $OCAMLFIND_DESTDIR/llvm/stublibs $OCAMLFIND_DESTDIR/stublibs
  '';

  installFlags = [
    "-C"
    "bindings/ocaml"
  ];

  passthru = {
    inherit libllvm;
  };

  meta = {
    inherit (libllvm.meta) license homepage;
    inherit (ocaml.meta) platforms;
    description = "OCaml bindings distributed with LLVM";
    maintainers = with lib.maintainers; [ vbgl ];
  };

}
