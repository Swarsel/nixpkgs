{
  lib,
  buildDunePackage,
  chrome-trace,
  cmdliner,
  cmdliner_1,
  cppo,
  csexp,
  dune-build-info,
  dune-rpc,
  dyn,
  jsonrpc,
  ocaml,
  ocaml-syntax-shims,
  ocamlformat-rpc-lib,
  octavius,
  omd,
  ordering,
  pp,
  ppx_yojson_conv_lib,
  re,
  result,
  stdlib-shims,
  stdune,
  uutf,
  yojson_2,
  version ?
    if lib.versionAtLeast ocaml.version "5.5" then
      "1.27.0"
    else if lib.versionAtLeast ocaml.version "5.4" then
      "1.26.0"
    else if lib.versionAtLeast ocaml.version "5.3" then
      "1.23.1"
    else if lib.versionAtLeast ocaml.version "5.2" then
      "1.21.0"
    else if lib.versionAtLeast ocaml.version "4.14" then
      "1.18.0"
    else if lib.versionAtLeast ocaml.version "4.13" then
      "1.10.5"
    else if lib.versionAtLeast ocaml.version "4.12" then
      "1.9.0"
    else
      "1.4.1",
}:

let
  jsonrpc_v = jsonrpc.override {
    inherit version;
  };
in
buildDunePackage {
  inherit (jsonrpc_v) version src;
  pname = "lsp";
  nativeBuildInputs = lib.optional (lib.versionOlder version "1.7.0") cppo;

  buildInputs =
    if lib.versionAtLeast version "1.17.0" then
      [
        pp
        re
        octavius
        dune-build-info
        dune-rpc
        omd
        cmdliner
        ocamlformat-rpc-lib
        dyn
        stdune
        chrome-trace
      ]
    else if lib.versionAtLeast version "1.12.0" then
      [
        pp
        re
        octavius
        dune-build-info
        dune-rpc
        omd
        cmdliner_1
        ocamlformat-rpc-lib
        dyn
        stdune
        chrome-trace
      ]
    else if lib.versionAtLeast version "1.10.0" then
      [
        pp
        re
        octavius
        dune-build-info
        dune-rpc
        omd
        cmdliner_1
        ocamlformat-rpc-lib
        dyn
        stdune
      ]
    else if lib.versionAtLeast version "1.7.0" then
      [
        re
        octavius
        dune-build-info
        omd
        cmdliner_1
        ocamlformat-rpc-lib
      ]
    else
      [
        ppx_yojson_conv_lib
        ocaml-syntax-shims
        octavius
        dune-build-info
        omd
        cmdliner_1
      ];

  propagatedBuildInputs =
    if lib.versionAtLeast version "1.23.1" then
      [
        jsonrpc
        ppx_yojson_conv_lib
        uutf
      ]
    else if lib.versionAtLeast version "1.14.0" then
      [
        jsonrpc
        (ppx_yojson_conv_lib.override { yojson = yojson_2; })
        uutf
      ]
    else if lib.versionAtLeast version "1.10.0" then
      [
        dyn
        jsonrpc
        ordering
        (ppx_yojson_conv_lib.override { yojson = yojson_2; })
        stdune
        uutf
      ]
    else if lib.versionAtLeast version "1.9.0" then
      [
        csexp
        jsonrpc
        (pp.override { version = "1.2.0"; })
        (ppx_yojson_conv_lib.override { yojson = yojson_2; })
        result
        uutf
      ]
    else if lib.versionAtLeast version "1.7.0" then
      [
        csexp
        jsonrpc
        (pp.override { version = "1.2.0"; })
        ppx_yojson_conv_lib
        result
        uutf
      ]
    else
      [
        csexp
        jsonrpc
        ppx_yojson_conv_lib
        stdlib-shims
        uutf
      ];

  # unvendor some (not all) dependencies.
  # They are vendored by upstream only because it is then easier to install
  # ocaml-lsp without messing with your opam switch, but nix should prevent
  # this type of problems without resorting to vendoring.
  preBuild = lib.optionalString (lib.versionOlder version "1.10.4") ''
    rm -r ocaml-lsp-server/vendor/{octavius,uutf,omd,cmdliner}
  '';

  minimalOCamlVersion = if lib.versionAtLeast version "1.7.0" then "4.12" else "4.06";

  meta = jsonrpc.meta // {
    description = "LSP protocol implementation in OCaml";
  };
}
