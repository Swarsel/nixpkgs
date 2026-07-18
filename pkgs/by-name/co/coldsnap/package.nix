{
  lib,
  fetchFromGitHub,
  openssl,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "coldsnap";
  version = "0.10.0";

  src = fetchFromGitHub {
    owner = "awslabs";
    repo = "coldsnap";
    rev = "v${finalAttrs.version}";
    hash = "sha256-QQWH8cWBskXOmiZygvkNDyBX4WdsgnA0/ec6/UnmwIA=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ];
  cargoHash = "sha256-U5MinzKQYTHRXM3WndkMEbvoT9tPwIIB3QxEOwWA3zE=";

  meta = {
    description = "Command line interface for Amazon EBS snapshots";
    homepage = "https://github.com/awslabs/coldsnap";
    changelog = "https://github.com/awslabs/coldsnap/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.asl20;
    mainProgram = "coldsnap";
  };
})
