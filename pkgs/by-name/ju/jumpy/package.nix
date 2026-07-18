{
  lib,
  stdenv,
  fetchFromGitHub,
  alsa-lib,
  fetchpatch2,
  libx11,
  libxcursor,
  libxi,
  libxkbcommon,
  libxrandr,
  makeWrapper,
  pkg-config,
  rustPlatform,
  udev,
  vulkan-loader,
  wayland,
  zstd,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "jumpy";
  version = "0.12.2";

  src = fetchFromGitHub {
    owner = "fishfolk";
    repo = "jumpy";
    tag = "v${finalAttrs.version}";
    hash = "sha256-g/CpSycTCM1i6O7Mir+3huabvr4EXghDApquEUNny8c=";
  };

  nativeBuildInputs = [
    makeWrapper
    pkg-config
  ];

  buildInputs = [
    zstd
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    alsa-lib
    libxkbcommon
    udev
    vulkan-loader
    wayland
    libx11
    libxcursor
    libxi
    libxrandr
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    rustPlatform.bindgenHook
  ];

  cargoHash = "sha256-2I9s1zH94GRqXGBxZYyXOQwNeYrpV1UhUSKGCs9Ce9Q=";

  env = {
    ZSTD_SYS_USE_PKG_CONFIG = true;
  };

  # jumpy only loads assets from the current directory
  # https://github.com/fishfolk/bones/blob/f84d07c2f2847d9acd5c07098fe1575abc496400/framework_crates/bones_asset/src/io.rs#L50
  postInstall = ''
    mkdir $out/share
    cp -r assets $out/share
    wrapProgram $out/bin/jumpy --chdir $out/share
  '';

  postFixup = lib.optionalString stdenv.hostPlatform.isLinux ''
    patchelf $out/bin/.jumpy-wrapped \
      --add-rpath ${lib.makeLibraryPath [ vulkan-loader ]}
  '';

  cargoBuildFlags = [
    "--bin"
    "jumpy"
  ];

  # This patch may be removed in the next release
  cargoPatches = [
    (fetchpatch2 {
      hash = "sha256-IWjBw1Wj/6CT/x6xm6vfpUMfk7A5/EsdbPDvWywRFc8=";
      url = "https://github.com/fishfolk/jumpy/commit/8234e6d2c0b33c75e2112596ded1734fdba50fb8.patch?full_index=1";
    })
  ];

  meta = {
    description = "Tactical 2D shooter played by up to 4 players online or on a shared screen";
    homepage = "https://fishfolk.org/games/jumpy";
    changelog = "https://github.com/fishfolk/jumpy/releases/tag/v${finalAttrs.version}";

    license = with lib.licenses; [
      mit # or
      asl20
      # Assets
      cc-by-nc-40
    ];

    maintainers = [ ];
    mainProgram = "jumpy";
  };
})
