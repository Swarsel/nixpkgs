with import ../../.. { };

stdenv.mkDerivation {
  nativeBuildInputs = [
    (rWrapper.override {
      packages = with rPackages; [
        data_table
        parallel
        BiocManager
        jsonlite
      ];
    })
  ];

  buildInputs = [
    wget
    cacert
    nix
  ];

  buildCommand = "exit 1";
  name = "generate-r-packages-shell";
}
