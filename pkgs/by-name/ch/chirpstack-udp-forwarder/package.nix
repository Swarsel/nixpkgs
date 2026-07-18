{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,
  protobuf,
  rustPlatform,
  versionCheckHook,
}:
rustPlatform.buildRustPackage rec {
  pname = "chirpstack-udp-forwarder";
  version = "4.3.0";

  src = fetchFromGitHub {
    owner = "chirpstack";
    repo = "chirpstack-udp-forwarder";
    rev = "v${version}";
    hash = "sha256-hGqkeDH/LHqBhpZQsss0jzMIQxhkryKucaLuWJtmseI=";
  };

  nativeBuildInputs = [ protobuf ];
  cargoHash = "sha256-WkFQXOY6JVjpw8UsrKgRgR6UzRBNOIg56zBqdcM9LuE=";
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "UDP packet-forwarder for the ChirpStack Concentratord";
    homepage = "https://www.chirpstack.io/";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.stv0g ];
    mainProgram = "chirpstack-udp-forwarder";
  };
}
