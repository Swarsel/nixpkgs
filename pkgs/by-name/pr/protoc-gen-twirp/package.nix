{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule rec {
  pname = "protoc-gen-twirp";
  version = "8.1.3";

  src = fetchFromGitHub {
    owner = "twitchtv";
    repo = "twirp";
    rev = "v${version}";
    sha256 = "sha256-p3gHVHGBHakOOQnJAuMK7vZumNXN15mOABuEHUG0wNs=";
  };

  postPatch = ''
    go mod init github.com/twitchtv/twirp
  '';

  vendorHash = null;

  subPackages = [
    "protoc-gen-twirp"
  ];

  meta = {
    description = "Simple RPC framework with protobuf service definitions";
    homepage = "https://github.com/twitchtv/twirp";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ jojosch ];
    mainProgram = "protoc-gen-twirp";
    # Marked broken 2025-11-28 because it has failed on Hydra for at least one year.
    broken = true;
  };
}
