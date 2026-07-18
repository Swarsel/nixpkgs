{
  lib,
  buildPackages,
  clippy,
  dbus,
  nixosTests,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage {
  pname = "switch-to-configuration";
  version = "0.1.0";
  src = builtins.filterSource (name: _: !(lib.hasSuffix ".nix" name)) ./.;
  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ dbus ];
  cargoLock.lockFile = ./Cargo.lock;
  env.SYSTEMD_DBUS_INTERFACE_DIR = "${buildPackages.systemd}/share/dbus-1/interfaces";

  nativeCheckInputs = [
    clippy
  ];

  preCheck = ''
    echo "Running clippy..."
    cargo clippy -- -Dwarnings
  '';

  passthru.tests = { inherit (nixosTests) switchTest activation-template-dropin; };

  meta = {
    description = "NixOS switch-to-configuration program";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ jmbaur ];
    mainProgram = "switch-to-configuration";
  };
}
