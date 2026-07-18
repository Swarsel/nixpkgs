{
  lib,
  coq,
  mkCoqDerivation,
  version ? null,
}:

mkCoqDerivation {
  inherit version;
  pname = "autosubst-ocaml";

  buildInputs = with coq.ocamlPackages; [
    angstrom
    ocamlgraph
    ppx_deriving
    ppxlib
  ];

  buildPhase = ''
    dune build
  '';

  installPhase = ''
    dune install --prefix $out --libdir $OCAMLFIND_DESTDIR
  '';

  defaultVersion =
    with lib.versions;
    lib.switch coq.coq-version [
      {
        case = isEq "9.0";
        out = "1.1+9.0";
      }
      {
        case = isEq "8.20";
        out = "1.1+8.20";
      }
      {
        case = isEq "8.19";
        out = "1.1+8.19";
      }
    ] null;

  owner = "uds-psl";
  release."1.1+8.19".hash = "sha256-AGbhw/6lg4GpDE6hZBhau9DLW7HVXa0UzGvJfSV8oHE=";
  release."1.1+8.20".hash = "sha256-S3uKkwbGFsvauP9lKc3UsdszHahbZQhlOOK3fCBXlSE=";
  release."1.1+9.0".hash = "sha256-fCQjmF+0ik2QdKog61VfIv5ERmw+AJO8y5+CWmDGGk0=";
  useDune = true;

  meta = {
    description = "OCaml reimplementation of the Autosubst 2 code generator";
    homepage = "https://github.com/uds-psl/autosubst-ocaml";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ chen ];
    mainProgram = "autosubst";
  };
}
