{
  lib,
  fetchFromGitHub,
  git,
  libgit2,
  makeWrapper,
  openssl,
  pkg-config,
  rustPlatform,
}:

let
  version = "26.05.08";
in

rustPlatform.buildRustPackage {
  inherit version;
  pname = "josh";

  src = fetchFromGitHub {
    owner = "josh-project";
    repo = "josh";
    rev = "r${version}";
    hash = "sha256-rG5ZkEH8ZL8t0sDnBnNPtVtaR1I8BoulXlFh0HCpMsw=";
  };

  nativeBuildInputs = [
    pkg-config
    makeWrapper
  ];

  buildInputs = [
    libgit2
    openssl
  ];

  cargoHash = "sha256-/hMn80jHDF9gh+K8IOV5zXllzJkCdcmvI/NmbKFd/uM=";
  # used to teach josh itself about its version number
  env.JOSH_VERSION = "r${version}";

  # josh and josh-filter are used interactively, so git is likely already in PATH
  postInstall = ''
    wrapProgram "$out/bin/josh-proxy" --prefix PATH : "${git}/bin"
  '';

  cargoBuildFlags = [ "--workspace" ];

  # josh-proxy's inline tests need to interact with a specific test environment
  cargoTestFlags = [
    "--workspace"
    "--exclude"
    "josh-proxy"
  ];

  meta = {
    description = "Just One Single History";
    homepage = "https://josh-project.github.io/josh/";
    changelog = "https://github.com/josh-project/josh/releases/tag/r${version}";
    license = lib.licenses.mit;

    maintainers = [
      lib.maintainers.sternenseemann
      lib.maintainers.tazjin
    ];

    platforms = lib.platforms.all;
    downloadPage = "https://github.com/josh-project/josh";
  };
}
