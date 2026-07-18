{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  withFilters ? false,
}:

let
  generic =
    { hash, version }:
    stdenv.mkDerivation {
      inherit version;
      pname = "h3";

      src = fetchFromGitHub {
        inherit hash;
        owner = "uber";
        repo = "h3";
        tag = "v${version}";
      };

      outputs = [
        "out"
        "dev"
      ];

      nativeBuildInputs = [ cmake ];

      cmakeFlags = [
        (lib.cmakeBool "BUILD_SHARED_LIBS" true)
        (lib.cmakeBool "BUILD_BENCHMARKS" false)
        (lib.cmakeBool "BUILD_FUZZERS" false)
        (lib.cmakeBool "BUILD_GENERATORS" false)
        (lib.cmakeBool "ENABLE_COVERAGE" false)
        (lib.cmakeBool "ENABLE_FORMAT" false)
        (lib.cmakeBool "ENABLE_LINTING" false)
        (lib.cmakeBool "BUILD_FILTERS" withFilters)
      ]
      ++ (lib.optionals (lib.versionOlder version "4.0.0") [ "-DCMAKE_POLICY_VERSION_MINIMUM=3.5" ]);

      meta = {
        description = "Hexagonal hierarchical geospatial indexing system";
        homepage = "https://h3geo.org/";
        changelog = "https://github.com/uber/h3/raw/v${version}/CHANGELOG.md";
        license = lib.licenses.asl20;
        maintainers = with lib.maintainers; [ kalbasit ];
        platforms = lib.platforms.all;
      };
    };
in
{
  h3_3 = generic {
    version = "3.7.2";
    hash = "sha256-MvWqQraTnab6EuDx4V0v8EvrFWHT95f2EHTL2p2kei8=";
  };

  h3_4 = generic {
    version = "4.4.1";
    hash = "sha256-tKonXauTJiOb5DV56tOmnvba7eNYcWTnOvCSokheVsY=";
  };
}
