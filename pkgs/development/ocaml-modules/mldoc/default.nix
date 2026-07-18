{
  lib,
  fetchFromGitHub,
  angstrom,
  buildDunePackage,
  cmdliner,
  core,
  core_bench,
  fetchpatch,
  js_of_ocaml,
  js_of_ocaml-ppx,
  lwt,
  ppx_deriving_yojson,
  uri,
  xmlm,
  yojson,
  core_unix ? null,
}:
let
  angstrom' = angstrom.overrideAttrs (attrs: {
    patches = attrs.patches or [ ] ++ [
      # mldoc requires Angstrom to expose `unsafe_lookahead`
      (fetchpatch {
        sha256 = "sha256-RapY1QJ8U0HOqJ9TFDnCYB4tFLFuThESzdBZqjYuDUA=";
        url = "https://github.com/logseq/angstrom/commit/bbe36c99c13678937d4c983a427e02a733d6cc24.patch";
      })
    ];
  });
  uri' = uri.override { angstrom = angstrom'; };
in
buildDunePackage (finalAttrs: {
  pname = "mldoc";
  version = "1.5.8";

  src = fetchFromGitHub {
    owner = "logseq";
    repo = "mldoc";
    rev = "v${finalAttrs.version}";
    hash = "sha256-7uuNUFMSQEgakTKfpYixp43gnfpQSW++snBzgr0Ni0Y=";
  };

  buildInputs = [
    cmdliner
    core
    core_bench
    core_unix
    js_of_ocaml
    js_of_ocaml-ppx
    lwt
  ];

  propagatedBuildInputs = [
    angstrom'
    uri'
    yojson
    ppx_deriving_yojson
    xmlm
  ];

  duneVersion = "3";
  minimalOCamlVersion = "4.10";

  meta = {
    description = "Another Emacs Org-mode and Markdown parser";
    homepage = "https://github.com/logseq/mldoc";
    license = lib.licenses.agpl3Only;
    maintainers = [ ];
  };
})
