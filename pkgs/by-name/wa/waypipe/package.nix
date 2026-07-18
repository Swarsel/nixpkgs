{
  lib,
  fetchFromGitLab,
  autoPatchelfHook,
  cargo,
  ffmpeg,
  libgbm,
  llvmPackages,
  lz4,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
  rust-bindgen,
  rustPlatform,
  rustc,
  scdoc,
  shaderc,
  vulkan-headers,
  vulkan-loader,
  wayland-scanner,
  zstd,
}:
llvmPackages.stdenv.mkDerivation (finalAttrs: {
  pname = "waypipe";
  version = "0.11.0";

  src = fetchFromGitLab {
    owner = "mstoeckl";
    repo = "waypipe";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Tbd/yY90yb2+/ODYVL3SudHaJCGJKatZ9FuGM2uAX+8=";
    domain = "gitlab.freedesktop.org";
  };

  strictDeps = true;

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    scdoc
    cargo
    shaderc # for glslc
    rustc
    wayland-scanner
    rustPlatform.cargoSetupHook
    autoPatchelfHook
    rust-bindgen
  ];

  buildInputs = [
    libgbm
    lz4
    zstd
    ffmpeg
    vulkan-headers
    vulkan-loader
  ];

  env.LIBCLANG_PATH = "${llvmPackages.libclang.lib}/lib";

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version src;
    hash = "sha256-IUvXHLxrhc2Au57wsE53Q+NL1cZzFcaRG3HDV8s3xWw=";
  };

  depsBuildBuild = [ pkg-config ];

  runtimeDependencies = [
    libgbm
    ffmpeg.lib
    vulkan-loader
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Network proxy for Wayland clients (applications)";

    longDescription = ''
      waypipe is a proxy for Wayland clients. It forwards Wayland messages and
      serializes changes to shared memory buffers over a single socket. This
      makes application forwarding similar to ssh -X feasible.
    '';

    homepage = "https://mstoeckl.com/notes/gsoc/blog.html";
    changelog = "https://gitlab.freedesktop.org/mstoeckl/waypipe/-/releases#v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ mic92 ];
    platforms = lib.platforms.linux;
    mainProgram = "waypipe";
  };
})
