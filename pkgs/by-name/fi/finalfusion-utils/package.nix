{
  lib,
  fetchFromGitHub,
  blas,
  gfortran,
  installShellFiles,
  lapack,
  openssl,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "finalfusion-utils";
  version = "0.14.1";

  src = fetchFromGitHub {
    owner = "finalfusion";
    repo = "finalfusion-utils";
    rev = finalAttrs.version;
    sha256 = "sha256-suzivynlgk4VvDOC2dQR40n5IJHoJ736+ObdrM9dIqE=";
  };

  nativeBuildInputs = [ installShellFiles ];

  buildInputs = [
    blas
    gfortran.cc.lib
    lapack
    openssl
  ];

  cargoHash = "sha256-X8ENEtjH1RHU2+VwtkHsyVYK37O8doMlLk94O2BGqy0=";

  postInstall = ''
    # Install shell completions
    for shell in bash fish zsh; do
      $out/bin/finalfusion completions $shell > finalfusion.$shell
    done
    installShellCompletion finalfusion.{bash,fish,zsh}
  '';

  # Enables build against a generic BLAS.
  buildFeatures = [ "netlib" ];

  meta = {
    description = "Utility for converting, quantizing, and querying word embeddings";
    homepage = "https://github.com/finalfusion/finalfusion-utils/";
    license = lib.licenses.asl20;
    maintainers = [ ];
    mainProgram = "finalfusion";
  };
})
