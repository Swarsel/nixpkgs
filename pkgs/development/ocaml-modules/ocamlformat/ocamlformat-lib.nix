# Version can be selected with the 'version' argument, see generic.nix.
{
  lib,
  buildDunePackage,
  callPackage,
  menhir,
  ...
}@args:

let
  inherit (callPackage ./generic.nix args) src version library_deps;

in
assert (lib.versionAtLeast version "0.25.1");

buildDunePackage {
  inherit src version;
  pname = "ocamlformat-lib";
  nativeBuildInputs = [ menhir ];
  propagatedBuildInputs = library_deps;

  meta = {
    description = "Auto-formatter for OCaml code (library)";
    homepage = "https://github.com/ocaml-ppx/ocamlformat";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      Zimmi48
      Julow
    ];
  };
}
