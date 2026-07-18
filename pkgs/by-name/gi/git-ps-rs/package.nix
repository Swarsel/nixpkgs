{
  lib,
  fetchFromGitHub,
  dbus,
  openssl,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "git-ps-rs";
  version = "7.3.1";

  src = fetchFromGitHub {
    owner = "uptech";
    repo = "git-ps-rs";
    rev = finalAttrs.version;
    hash = "sha256-4lk6AHquWKgDk0pBaswbVShZbUDA3wO6cPakhrvrwac=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    openssl
    dbus
  ];

  cargoHash = "sha256-QYkEBqDwspdhSliwLwMWmybS9nd41DCjGNURnMzLzBM=";

  meta = {
    description = "Tool for working with a stack of patches";
    homepage = "https://git-ps.sh/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ alizter ];
    mainProgram = "gps";
  };
})
