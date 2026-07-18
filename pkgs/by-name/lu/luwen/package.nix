{
  lib,
  fetchFromGitHub,
  protobuf,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "luwen";
  version = "0.8.5";

  src = fetchFromGitHub {
    owner = "tenstorrent";
    repo = "luwen";
    tag = "v${finalAttrs.version}";
    hash = "sha256-lY7cZ+8C0UEGGYxufl4Vi8g0L4AJFXaGqn7XE2ivTcQ=";
  };

  nativeBuildInputs = [
    protobuf
  ];

  cargoHash = "sha256-QBGXbRiBk4WIQFopq1OccmUHgx5GzR/PKhMH4Ie+fyg=";
  __structuredAttrs = true;

  meta = {
    description = "Tenstorrent system interface tools";
    homepage = "https://github.com/tenstorrent/luwen";
    license = with lib.licenses; [ asl20 ];
    maintainers = with lib.maintainers; [ RossComputerGuy ];
  };
})
