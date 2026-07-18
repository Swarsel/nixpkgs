{
  lib,
  dbus,
  fetchFromCodeberg,
  networkmanager,
  nix-update-script,
  pkg-config,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "nm-file-secret-agent";
  version = "1.2.0";

  src = fetchFromCodeberg {
    owner = "lilly";
    repo = "nm-file-secret-agent";
    rev = "v${finalAttrs.version}";
    hash = "sha256-exU+9fN2Wt2+0lQoZS4TFPhCcoDPWEIZldRO9LKux3U=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ dbus ];
  cargoHash = "sha256-jxeEubl1uXmnapvP2OV4jCQWoavAVPbSPL1C3fFtJlE=";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "NetworkManager secret agent that responds with the content of preconfigured files";
    homepage = "https://codeberg.org/lilly/nm-file-secret-agent";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ lilioid ];
    platforms = lib.lists.intersectLists dbus.meta.platforms networkmanager.meta.platforms;
    mainProgram = "nm-file-secret-agent";
  };
})
