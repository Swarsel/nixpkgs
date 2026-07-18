{
  lib,
  fetchFromGitHub,
  go-md2man,
  installShellFiles,
  mandown,
  nixosTests,
  protobuf,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "netavark";
  version = "1.17.2";

  src = fetchFromGitHub {
    owner = "containers";
    repo = "netavark";
    rev = "v${finalAttrs.version}";
    hash = "sha256-FdJNcHYK6Jc1dNqcUr5Ne8dv1dzlHRhcjoldiihrov8=";
  };

  nativeBuildInputs = [
    installShellFiles
    mandown
    protobuf
    go-md2man
  ];

  cargoHash = "sha256-wp/1lWc3OfNQt74m8DtpuFO/Mf07+M7numq2FMEkeGo=";

  postBuild = ''
    make -C docs netavark.1
    installManPage docs/netavark.1
  '';

  passthru.tests = { inherit (nixosTests) podman; };

  meta = {
    description = "Rust based network stack for containers";
    homepage = "https://github.com/containers/netavark";
    changelog = "https://github.com/containers/netavark/releases/tag/${finalAttrs.src.rev}";
    license = lib.licenses.asl20;
    platforms = lib.platforms.linux;
    teams = [ lib.teams.podman ];
  };
})
