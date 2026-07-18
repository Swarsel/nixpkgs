{
  lib,
  stdenv,
  fetchFromGitHub,
  autoPatchelfHook,
  libxkbcommon,
  nix-update-script,
  pkg-config,
  rustPlatform,
  vulkan-loader,
  wayland,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "cantus";
  version = "0.6.8";

  src = fetchFromGitHub {
    owner = "CodedNil";
    repo = "cantus";
    tag = finalAttrs.version;
    hash = "sha256-TRqWhoRlinNzLdxODs4bR5IgJR6ELKs4SOOpvtoFNFA=";
  };

  nativeBuildInputs = [
    pkg-config
    autoPatchelfHook
  ];

  buildInputs = [
    stdenv.cc.cc.lib
  ];

  cargoHash = "sha256-YUXEgeZn0UXh34RnCaqLhhK0QSPz3Y8XJuR2oMa4rIU=";

  runtimeDependencies = [
    libxkbcommon
    vulkan-loader
    wayland
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Beautiful interactive music widget for Wayland";
    homepage = "https://github.com/CodedNil/cantus";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ CodedNil ];
    platforms = lib.platforms.linux;
    mainProgram = "cantus";
  };
})
