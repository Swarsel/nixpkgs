{
  lib,
  fetchFromGitHub,
  capnproto,
  protobuf,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "conmon-rs";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "containers";
    repo = "conmon-rs";
    rev = "v${finalAttrs.version}";
    hash = "sha256-aeicug8d5RKFgq7ZSGBN7qY0PvlZcTeMwYMYXTS3Gvw=";
  };

  nativeBuildInputs = [
    capnproto
    protobuf
  ];

  cargoHash = "sha256-8GtwbX+FOE+upKJbQFGv+RJDZHPNMcA5SUTPK6qgrIs=";
  doCheck = false;

  meta = {
    description = "OCI container runtime monitor written in Rust";
    homepage = "https://github.com/containers/conmon-rs";
    license = lib.licenses.asl20;
    platforms = lib.platforms.linux;
    teams = [ lib.teams.podman ];
  };
})
