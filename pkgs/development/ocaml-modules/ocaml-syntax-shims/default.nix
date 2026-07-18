{
  lib,
  fetchurl,
  buildDunePackage,
}:

buildDunePackage (finalAttrs: {
  pname = "ocaml-syntax-shims";
  version = "1.0.0";

  src = fetchurl {
    url = "https://github.com/ocaml-ppx/ocaml-syntax-shims/releases/download/${finalAttrs.version}/ocaml-syntax-shims-${finalAttrs.version}.tbz";
    hash = "sha256-ibLhk+kKDBaLbsXd9v7wkDNoG9y2ThGRPJdECici6Mg=";
  };

  doCheck = true;

  meta = {
    description = "Backport new syntax to older OCaml versions";
    homepage = "https://github.com/ocaml-ppx/ocaml-syntax-shims";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ sternenseemann ];
    mainProgram = "ocaml-syntax-shims";
  };
})
