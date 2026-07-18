{
  lib,
  fetchFromGitHub,
  alsa-lib,
  android-tools,
  autoAddDriverRunpath,
  brotli,
  bzip2,
  callPackage,
  celt,
  fetchpatch,
  gmp,
  jack2,
  lame,
  libdrm,
  libglvnd,
  libogg,
  libpng,
  libtheora,
  libunwind,
  libva,
  libvdpau,
  libx11,
  libxcursor,
  libxi,
  libxkbcommon,
  libxrandr,
  nix-update-script,
  openapv,
  openssl,
  openvr,
  pipewire,
  pkg-config,
  replaceVars,
  rust-cbindgen,
  rustPlatform,
  soxr,
  vulkan-headers,
  vulkan-loader,
  wayland,
  x264,
  xvidcore,
  ffmpeg-alvr ? callPackage ./ffmpeg.nix { },
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "alvr";
  version = "20.14.1";

  src = fetchFromGitHub {
    owner = "alvr-org";
    repo = "ALVR";
    tag = "v${finalAttrs.version}";
    hash = "sha256-9fckUhUPAbcmbqOdUO8RlwuK8/nf1fc7XQBrAu5YaR4=";
    fetchSubmodules = true; # TODO devendor openvr
  };

  patches = [
    (replaceVars ./fix-finding-libs.patch {
      ffmpeg = lib.getDev ffmpeg-alvr;
      x264 = lib.getDev x264;
    })
    (fetchpatch {
      hash = "sha256-yvIGjopXIwGXajs5/RlAo+eqfVNnXlomKy/VO/dL+gc=";
      url = "https://github.com/alvr-org/ALVR/commit/12a238b9ac9d63438163ff82cbd689733558a1e4.patch";
    })
  ];

  nativeBuildInputs = [
    rust-cbindgen
    pkg-config
    rustPlatform.bindgenHook
    autoAddDriverRunpath
  ];

  buildInputs = [
    alsa-lib
    android-tools
    brotli
    bzip2
    celt
    ffmpeg-alvr
    gmp
    jack2
    lame
    libx11
    libxcursor
    libxi
    libxrandr
    libdrm
    libglvnd
    libogg
    libpng
    libtheora
    libunwind
    libva
    libvdpau
    libxkbcommon
    openapv
    openssl
    openvr
    pipewire
    soxr
    vulkan-headers
    vulkan-loader
    wayland
    x264
    xvidcore
  ];

  cargoHash = "sha256-OTCMWrlwnfpUhm6ssOE133e/3DaQFnOU+NunN2c1N+g=";

  env = {
    NIX_CFLAGS_COMPILE = toString [
      "-lbrotlicommon"
      "-lbrotlidec"
      "-lcrypto"
      "-lpng"
      "-lssl"
    ];

    RUSTFLAGS = toString (
      map (a: "-C link-arg=${a}") [
        "-Wl,--push-state,--no-as-needed"
        "-lEGL"
        "-lwayland-client"
        "-lxkbcommon"
        "-Wl,--pop-state"
      ]
    );
  };

  postBuild = ''
    # Build SteamVR driver ("streamer")
    cargo xtask build-streamer --release
  '';

  postInstall = ''
    install -Dm755 ${finalAttrs.src}/alvr/xtask/resources/alvr.desktop $out/share/applications/alvr.desktop
    install -Dm644 ${finalAttrs.src}/resources/ALVR-Icon.svg $out/share/icons/hicolor/scalable/apps/alvr.svg

    # Install SteamVR driver
    mkdir -p $out/{libexec,lib/alvr,share}
    cp -r ./build/alvr_streamer_linux/lib64/. $out/lib
    cp -r ./build/alvr_streamer_linux/libexec/. $out/libexec
    cp -r ./build/alvr_streamer_linux/share/. $out/share
    ln -s $out/lib $out/lib64
  '';

  cargoBuildFlags = [
    "--exclude=alvr_xtask"
    "--workspace"
  ];

  passthru = {
    inherit ffmpeg-alvr;
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Stream VR games from your PC to your headset via Wi-Fi";
    homepage = "https://github.com/alvr-org/ALVR/";
    changelog = "https://github.com/alvr-org/ALVR/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      luNeder
      jopejoe1
      eyjhb
    ];

    platforms = lib.platforms.linux;
    mainProgram = "alvr_dashboard";
  };
})
