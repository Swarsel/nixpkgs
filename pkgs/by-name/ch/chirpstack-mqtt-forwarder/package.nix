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
  pname = "chirpstack-mqtt-forwarder";
  version = "4.5.1";

  src = fetchFromGitHub {
    owner = "chirpstack";
    repo = "chirpstack-mqtt-forwarder";
    rev = "v${version}";
    hash = "sha256-AFyvXLXGs1jeOJM8tSKBNbTVYr5SRUscqnUlSvU9iuA=";
  };

  nativeBuildInputs = [ protobuf ];
  cargoHash = "sha256-mRmvKOqfzqUvPexRbd9TRS2lunpne7+wO57bsYZ3dXw=";

  checkFlags = [
    "--skip=end_to_end" # Depends on internet connectivity
  ];

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Forwarder which can be installed on the gateway to forward LoRa data over MQTT";
    homepage = "https://www.chirpstack.io/";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.stv0g ];
    mainProgram = "chirpstack-mqtt-forwarder";
  };
}
