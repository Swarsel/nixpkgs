{
  lib,
  stdenv,
  fetchurl,
  buildPackages,
  version ? "3.23.1",
}:
let
  # needed for pkgsStatic
  inherit (buildPackages.buildPackages) ocamlPackages;
in
stdenv.mkDerivation {
  inherit version;
  pname = "dune";

  src = fetchurl {
    url =
      let
        sfx = lib.optionalString (lib.versions.major version == "2") "site-";
      in
      "https://github.com/ocaml/dune/releases/download/${version}/dune-${sfx}${version}.tbz";

    hash =
      {
        "2.9.3" = "sha256:1ml8bxym8sdfz25bx947al7cvsi2zg5lcv7x9w6xb01cmdryqr9y";
        "3.21.1" = "sha256-hPeoLG2ApxJPOEfppInoDPvq+3vtNXOsAShu9W/QjZQ=";
        "3.22.2" = "sha256-wsz4vGsXr6R8RQKXNXSWMDqnyGgOMpt52Yxo41AToRg=";
        "3.23.1" = "sha256-k7TnFX9rqP62HPxfhgCO/SxZA3unigF9krSr8wYyNI8=";
      }
      ."${version}";
  };

  strictDeps = true;

  nativeBuildInputs = with ocamlPackages; [
    ocaml
    findlib
  ];

  buildFlags = [ "release" ];
  __structuredAttrs = true;
  configurePlatforms = [ ];
  depsBuildBuild = [ buildPackages.stdenv.cc ];
  dontAddPrefix = true;
  dontAddStaticConfigureFlags = true;

  installFlags = [
    "PREFIX=${placeholder "out"}"
    "LIBDIR=$(OCAMLFIND_DESTDIR)"
  ];

  passthru.tests = {
    inherit (ocamlPackages) ocaml-lsp dune-release;
  };

  meta = {
    inherit (ocamlPackages.ocaml.meta) platforms;
    description = "Composable build system";
    homepage = "https://dune.build/";
    changelog = "https://github.com/ocaml/dune/raw/${version}/CHANGES.md";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.vbgl ];
    mainProgram = "dune";
  };
}
