{
  lib,
  mathcomp,
  mathcomp-bigenough,
  mathcomp-finmap,
  mathcomp-real-closed,
  mkRocqDerivation,
  rocq-core,
  stdlib,
  single ? false,
  version ? null,
}@args:

let
  repo = "analysis";
  owner = "math-comp";

  release."1.16.0".sha256 = "sha256-L0dCbxEqxI8rFv6OOEoIT/U3GKX37ageU9yw2H6hrWY=";

  defaultVersion =
    let
      case = rocq: mc: out: {
        inherit out;

        cases = [
          rocq
          mc
        ];
      };
    in
    with lib.versions;
    lib.switch
      [ rocq-core.rocq-version mathcomp.version ]
      [
        (case (range "9.0" "9.1") (range "2.4.0" "2.5.0") "1.16.0")
      ]
      null;

  # list of analysis packages sorted by dependency order
  packages = {
    "analysis" = [ "reals" ];

    "analysis-stdlib" = [
      "analysis"
      "reals-stdlib"
    ];

    "classical" = [ ];
    "experimental-reals" = [ "analysis" ];
    "reals" = [ "classical" ];
    "reals-stdlib" = [ "reals" ];
  };

  mathcomp_ =
    package:
    let
      classical-deps = [
        mathcomp.algebra
        mathcomp-finmap
      ];
      experimental-reals-deps = [ mathcomp-bigenough ];
      analysis-deps = [
        mathcomp.field
        mathcomp-bigenough
        mathcomp-real-closed
      ];
      intra-deps = lib.optionals (package != "single") (map mathcomp_ packages.${package});
      pkgpath =
        let
          case = case: out: { inherit case out; };
        in
        lib.switch package [
          (case "single" ".")
          (case "analysis" "theories")
          (case "experimental-reals" "experimental_reals")
          (case "reals-stdlib" "reals_stdlib")
          (case "analysis-stdlib" "analysis_stdlib")
        ] package;
      pname = if package == "single" then "mathcomp-analysis-single" else "mathcomp-${package}";
      derivation = mkRocqDerivation {
        inherit
          version
          pname
          defaultVersion
          release
          repo
          owner
          ;

        propagatedBuildInputs =
          intra-deps
          ++ lib.optionals (lib.elem package [
            "classical"
            "single"
          ]) classical-deps
          ++ lib.optionals (lib.elem package [
            "experimental-reals"
            "single"
          ]) experimental-reals-deps
          ++ lib.optionals (lib.elem package [
            "analysis"
            "single"
          ]) analysis-deps
          ++ lib.optional (lib.elem package [
            "reals-stdlib"
            "analysis-stdlib"
            "single"
          ]) stdlib;

        preBuild = ''
          cd ${pkgpath}
        '';

        namePrefix = [
          "rocq-core"
          "mathcomp"
        ];

        passthru = lib.mapAttrs (package: deps: mathcomp_ package) packages;

        meta = {
          description = "Analysis library compatible with Mathematical Components";
          license = lib.licenses.cecill-c;
          maintainers = [ lib.maintainers.cohencyril ];
        };
      };
    in
    derivation;
in
mathcomp_ (if single then "single" else "analysis")
