{
  lib,
  fetchFromGitHub,
  bzip2,
  installShellFiles,
  openssl,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "cargo-make";
  version = "0.37.24";

  src = fetchFromGitHub {
    owner = "sagiegurari";
    repo = "cargo-make";
    tag = finalAttrs.version;
    hash = "sha256-hrUd4J15cDyd78BVVzi8jiDqJI1dE35WUdOo6Tq8gH8=";
  };

  nativeBuildInputs = [
    pkg-config
    installShellFiles
  ];

  buildInputs = [
    bzip2
    openssl
  ];

  cargoHash = "sha256-ml/OW4S4fIMLmm7vVPgsXB7CigDYORGFpN3jZRp1f8c=";
  # Some tests fail because they need network access.
  # However, Travis ensures a proper build.
  # See also:
  #   https://travis-ci.org/sagiegurari/cargo-make
  doCheck = false;

  postInstall = ''
    installShellCompletion extra/shell/*.bash
  '';

  meta = {
    description = "Rust task runner and build tool";
    homepage = "https://github.com/sagiegurari/cargo-make";
    changelog = "https://github.com/sagiegurari/cargo-make/blob/${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      xrelkd
    ];

    mainProgram = "cargo-make";
  };
})
