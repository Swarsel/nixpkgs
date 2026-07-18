{
  lib,
  fetchFromGitHub,
  ocamlPackages,
}:

let
  inherit (ocamlPackages)
    buildDunePackage
    cmdliner
    github
    github-unix
    lwt_ssl
    opam-core
    opam-format
    opam-state
    ;
in

buildDunePackage (finalAttrs: {
  pname = "opam-publish";
  version = "2.7.1";

  src = fetchFromGitHub {
    owner = "ocaml-opam";
    repo = "opam-publish";
    tag = finalAttrs.version;
    hash = "sha256-yaFkR+MxkN6/skXx9euKVjTGXk9DraxDj+/2XQuHK4I=";
  };

  buildInputs = [
    cmdliner
    lwt_ssl
    opam-core
    opam-format
    opam-state
    github
    github-unix
  ];

  meta = {
    description = "Tool to ease contributions to opam repositories";
    homepage = "https://github.com/ocaml-opam/opam-publish";

    license = with lib.licenses; [
      lgpl21Only
      ocamlLgplLinkingException
    ];

    maintainers = with lib.maintainers; [ niols ];
    mainProgram = "opam-publish";
  };
})
