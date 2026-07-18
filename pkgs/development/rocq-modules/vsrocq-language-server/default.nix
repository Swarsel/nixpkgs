{
  lib,
  adwaita-icon-theme,
  coq,
  glib,
  metaFetch,
  rocq-core,
  wrapGAppsHook3,
  version ? null,
}:

let
  ocamlPackages = rocq-core.ocamlPackages;
  defaultVersion =
    let
      case = case: out: { inherit case out; };
    in
    lib.switch rocq-core.rocq-version [
      # When updating the default version here, also update the VsRocq VS Code extension
      (case (lib.versions.range "8.18" "9.1") "2.4.3")
    ] null;
  location = {
    domain = "github.com";
    owner = "rocq-prover";
    repo = "vsrocq";
  };
  fetch = metaFetch {
    inherit location;
    release."2.3.0".rev = "v2.3.0";
    release."2.3.0".sha256 = "sha256-BZLxcCmSGFf04eUmlJXnyxmg4hTwpFaPaIik4VD444M=";
    release."2.3.3".rev = "v2.3.3";
    release."2.3.3".sha256 = "sha256-wgn28wqWhZS4UOLUblkgXQISgLV+XdSIIEMx9uMT/ig=";
    release."2.3.4".rev = "v2.3.4";
    release."2.3.4".sha256 = "sha256-v1hQjE8U1o2VYOlUjH0seIsNG+NrMNZ8ixt4bQNyGvI=";
    release."2.4.3".rev = "v2.4.3";
    release."2.4.3".sha256 = "sha256-R/fpTiYZ9uvtKQcWD4jwUZPvUrcdvHc/wpoTrdkEQoQ=";
  };
  fetched = fetch (if version != null then version else defaultVersion);
in
ocamlPackages.buildDunePackage {
  inherit (fetched) version;
  pname = "vsrocq-language-server";
  src = "${fetched.src}/language-server";
  nativeBuildInputs = [ coq ];

  buildInputs = [
    coq
    glib
    adwaita-icon-theme
    wrapGAppsHook3
  ]
  ++ (with ocamlPackages; [
    findlib
    lablgtk3-sourceview3
    zarith
    ppx_inline_test
    ppx_assert
    ppx_sexp_conv
    ppx_deriving
    ppx_import
    sexplib
    (ppx_yojson_conv.override {
      ppx_yojson_conv_lib = ppx_yojson_conv_lib.override { yojson = yojson_2; };
    })
    lsp
    sel
    ppx_optcomp
  ]);

  preBuild = ''
    make dune-files
  '';

  meta = {
    description = "Language server for the vsrocq vscode/codium extension";
    homepage = "https://github.com/rocq-prover/vsrocq";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ cohencyril ];
  }
  // lib.optionalAttrs (fetched.broken or false) {
    broken = true;
  };
}
