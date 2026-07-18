{
  lib,
  stdenv,
  fetchFromGitHub,
  fontconfig,
  freetype,
  libxkbcommon,
  nix-update-script,
  openssl,
  pkg-config,
  protobuf,
  rustPlatform,
  versionCheckHook,
  vulkan-loader,
  wayland,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "objdiff";
  version = "3.7.3";

  src = fetchFromGitHub {
    owner = "encounter";
    repo = "objdiff";
    tag = "v${finalAttrs.version}";
    hash = "sha256-2Rzoj8JXv9MOGRHWiIodaBbP8ID+8RFJFuB3hzrodh8=";
  };

  nativeBuildInputs = [
    pkg-config
    protobuf
  ];

  buildInputs = [
    fontconfig
    freetype
    libxkbcommon
    openssl
    vulkan-loader
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    wayland
  ];

  cargoHash = "sha256-Z9vyUj35nrHuUoOYM54RLCn7CzcQ6k3A6FsDYKCVqVM=";
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  __structuredAttrs = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Local diffing tool for decompilation projects";
    homepage = "https://github.com/encounter/objdiff";

    license = with lib.licenses; [
      asl20
      mit
    ];

    maintainers = with lib.maintainers; [ Br1ght0ne ];
    mainProgram = "objdiff";
  };
})
