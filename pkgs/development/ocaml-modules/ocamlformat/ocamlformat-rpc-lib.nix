# Version can be selected with the 'version' argument, see generic.nix.
{
  lib,
  buildDunePackage,
  callPackage,
  csexp,
  ocaml,
  sexplib0,
  ...
}@args:

let
  # for compat with ocaml-lsp
  version_arg = if lib.versionAtLeast ocaml.version "4.13" then { } else { version = "0.20.0"; };

  inherit (callPackage ./generic.nix (args // version_arg)) src version;

in
buildDunePackage {
  inherit src version;
  pname = "ocamlformat-rpc-lib";

  propagatedBuildInputs = [
    csexp
    sexplib0
  ];

  meta = {
    description = "Auto-formatter for OCaml code (RPC mode)";
    homepage = "https://github.com/ocaml-ppx/ocamlformat";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      Zimmi48
      Julow
    ];
  };
}
