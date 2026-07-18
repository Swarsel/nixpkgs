{
  lib,
  stdenv,
  fetchFromGitHub,
  callPackage,
  fixDarwinDylibNames,
  nix-update-script,
  rustPlatform,
  vulkan-loader,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "wgpu-native";
  version = "27.0.4.0";

  src = fetchFromGitHub {
    owner = "gfx-rs";
    repo = "wgpu-native";
    tag = "v${finalAttrs.version}";
    hash = "sha256-XOT6Wx5TfbFzwcSjoyqUwv7mbN0RShaMf99qADmCKxg=";
    fetchSubmodules = true;
  };

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs = [
    rustPlatform.bindgenHook
  ]
  ++ lib.optional stdenv.hostPlatform.isDarwin fixDarwinDylibNames;

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    vulkan-loader
  ];

  cargoHash = "sha256-PZHS2lUX6PbIG1xF6jhreGjdtCbS/GWeY1pHhRPo2aU=";
  env.WGPU_NATIVE_VERSION = finalAttrs.version;

  postInstall = ''
    rm $out/lib/libwgpu_native.a
    install -Dm644 ./ffi/wgpu.h -t $dev/include/webgpu
    install -Dm644 ./ffi/webgpu-headers/webgpu.h -t $dev/include/webgpu
  '';

  passthru = {
    examples = callPackage ./examples.nix {
      inherit (finalAttrs) version src;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Native WebGPU implementation based on wgpu-core";
    homepage = "https://github.com/gfx-rs/wgpu-native";

    license = with lib.licenses; [
      mit
      asl20
    ];

    maintainers = with lib.maintainers; [ niklaskorz ];
  };
})
