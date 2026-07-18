{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "oauth2l";
  version = "1.3.3";

  src = fetchFromGitHub {
    owner = "google";
    repo = "oauth2l";
    rev = "v${finalAttrs.version}";
    hash = "sha256-jD8VFyAq6qcQhgvMmJj3D1xWGUvq3tMISbztLf1a72I=";
  };

  vendorHash = null;
  # tests fail on linux for some reason
  doCheck = stdenv.hostPlatform.isDarwin;
  # Fix tests by preventing them from writing to /homeless-shelter.
  preCheck = "export HOME=$(mktemp -d)";

  ldflags = [
    "-s"
    "-w"
  ];

  meta = {
    description = "Simple CLI for interacting with Google API authentication";
    homepage = "https://github.com/google/oauth2l";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ happysalada ];
    mainProgram = "oauth2l";
  };
})
