{
  lib,
  coq,
  metarocq-erasure,
  mkCoqDerivation,
  stdlib,
  which,
  single ? false,
  version ? null,
}:

let
  pname = "TypedExtraction";
  repo = "rocq-typed-extraction";
  owner = "peregrine-project";
  domain = "github.com";

  inherit version;
  defaultVersion =
    let
      case = coq: mr: out: {
        inherit out;

        cases = [
          coq
          mr
        ];
      };
    in
    lib.switch
      [
        coq.coq-version
        metarocq-erasure.version
      ]
      [
        (case "9.1" "1.5.1-9.1" "0.2.1")
        (case "9.1" (lib.versions.range "1.4" "1.4.1") "0.2.0")
      ]
      null;
  release = {
    "0.2.0".hash = "sha256-rgg39X45IXjcnejBhh8N7wMiH+gHQrfO8pBbFEWOGVI=";
    "0.2.1".hash = "sha256-GWdu/l7CipeBubgS5OGHsZfpP2Fkr1cfiZMRH5d1n0g=";
  };
  releaseRev = v: "v${v}";

  packages = {
    "all" = [
      "plugin"
    ];

    "common" = [ ];

    "elm" = [
      "common"
    ];

    "plugin" = [
      "elm"
      "rust"
    ];

    "rust" = [
      "common"
    ];
  };

  typedextraction_ =
    package:
    let
      typedextraction-deps = lib.optionals (package != "single") (
        map typedextraction_ packages.${package}
      );
      pkgpath = if package == "single" then "./" else "./${package}";
      pname = if package == "all" then "TypedExtraction" else "TypedExtraction-${package}";
      pkgallMake = ''
        mkdir all
        echo "all:" > all/Makefile
        echo "install:" >> all/Makefile
      '';
      derivation = (
        mkCoqDerivation (
          {
            inherit
              version
              pname
              defaultVersion
              release
              releaseRev
              repo
              owner
              ;

            propagatedBuildInputs = [
              stdlib
              coq.ocamlPackages.findlib
              metarocq-erasure
            ]
            ++ typedextraction-deps;

            preBuild = ''
              cd ${pkgpath}
            '';

            configurePhase =
              lib.optionalString (package == "all") pkgallMake
              + ''
                touch ${pkgpath}/_config
              ''
              + lib.optionalString (package == "single") ''
                ./configure.sh local
              '';

            mlPlugin = true;

            patchPhase = ''
              patchShebangs ./configure.sh
              patchShebangs ./plugin/process_extraction.sh
            '';

            meta = {
              description = "A framework for extracting Rocq programs to Rust and Elm";
              homepage = "https://peregrine-project.github.io/";
              license = lib.licenses.mit;
              maintainers = with lib.maintainers; [ _4ever2 ];
            };
          }
          // lib.optionalAttrs (package != "single") {
            passthru = lib.mapAttrs (package: deps: typedextraction_ package) packages;
          }
        )
      );
    in
    derivation;
in
typedextraction_ (if single then "single" else "all")
