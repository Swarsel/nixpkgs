{
  lib,
  fetchFromGitHub,
  # buildInputs
  dbus,
  nix-update-script,
  # nativeBuildInputs
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "hyprproxlock";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "Da4ndo";
    repo = "hyprproxlock";
    tag = finalAttrs.version;
    hash = "sha256-EoMxYMQBRP1fDfUorrkrgKDrVI88Ctusp2+1a7tnSU0=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    dbus
  ];

  cargoHash = "sha256-rBZ3acHStmUzEU+lsFhNYvLVPeeZe6P+4OHyxHRe4CU=";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Proximity-based daemon for Hyprland that triggers screen locking and unlocking through hyprlock based on Bluetooth device proximity";

    longDescription = ''
      A proximity-based daemon for Hyprland that triggers screen locking and unlocking through hyprlock based on Bluetooth device proximity.
      It monitors connected devices' signal strength to automatically control your screen lock state.
    '';

    homepage = "https://github.com/Da4ndo/hyprproxlock";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ shymega ];
    mainProgram = "hyprproxlock";
  };
})
