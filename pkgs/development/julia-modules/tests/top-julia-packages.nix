with import ../../../../. { };

let
  package-requests = stdenv.mkDerivation {
    buildInputs = [
      cacert
      gzip
      wget
    ];

    __impure = true;

    buildCommand = ''
      wget https://julialang-logs.s3.amazonaws.com/public_outputs/current/package_requests.csv.gz
      gunzip package_requests.csv.gz
      cp package_requests.csv $out
    '';

    name = "julia-package-requests.csv";
  };

  registry = callPackage ../registry.nix { };

in

runCommand "top-julia-packages.yaml"
  {
    nativeBuildInputs = [
      (python3.withPackages (
        ps: with ps; [
          pyyaml
          toml
        ]
      ))
    ];

    __impure = true;
  }
  ''
    python ${./process_top_n.py} ${package-requests} ${registry} > $out
  ''
