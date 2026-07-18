{
  lib,
  fetchurl,
  alcotest,
  bigstringaf,
  buildDunePackage,
  crowbar,
  cstruct,
  domain-local-await,
  fmt,
  hmap,
  lwt-dllist,
  mdx,
  mtime,
  ocaml,
  optint,
  psq,
  version ?
    if lib.versionAtLeast ocaml.version "5.2" then
      "1.3"
    else if lib.versionAtLeast ocaml.version "5.1" then
      "1.2"
    else
      "0.12",
}:

let
  param =
    {
      "0.12" = {
        hash = "sha256-2EhHzoX/t4ZBSWrSS+PGq1zCxohc7a1q4lfsrFnZJqA=";
        minimalOCamlVersion = "5.0";
      };

      "1.2" = {
        hash = "sha256-N5LpEr2NSUuy449zCBgl5NISsZcM8sHxspZsqp/WvEA=";
        minimalOCamlVersion = "5.1";
      };

      "1.3" = {
        hash = "sha256-jtXBPmaJ8xyF3KXxJ2LYS4zABCp7B9PkZN9utLcrPfw=";
        minimalOCamlVersion = "5.2";
      };
    }
    ."${version}";
in
buildDunePackage {
  inherit version;
  inherit (param) minimalOCamlVersion;
  pname = "eio";

  src = fetchurl {
    inherit (param) hash;
    url = "https://github.com/ocaml-multicore/eio/releases/download/v${version}/eio-${version}.tbz";
  };

  propagatedBuildInputs = [
    bigstringaf
    cstruct
    domain-local-await
    fmt
    hmap
    lwt-dllist
    mtime
    optint
    psq
  ];

  nativeCheckInputs = [
    mdx.bin
  ];

  checkInputs = [
    alcotest
    crowbar
    mdx
  ];

  meta = {
    description = "Effects-Based Parallel IO for OCaml";
    homepage = "https://github.com/ocaml-multicore/eio";
    changelog = "https://github.com/ocaml-multicore/eio/raw/v${version}/CHANGES.md";
    license = with lib.licenses; [ isc ];
    maintainers = with lib.maintainers; [ toastal ];
  };
}
