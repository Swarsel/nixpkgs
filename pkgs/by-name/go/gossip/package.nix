{
  lib,
  stdenv,
  fetchFromGitHub,
  SDL2,
  cmake,
  copyDesktopItems,
  ffmpeg_6,
  fontconfig,
  git,
  libGL,
  libx11,
  libxcb,
  libxcursor,
  libxi,
  libxkbcommon,
  libxrandr,
  makeDesktopItem,
  nix-update-script,
  openssl,
  pkg-config,
  rustPlatform,
  wayland,
  wayland-scanner,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "gossip";
  version = "0.14.0";

  src = fetchFromGitHub {
    owner = "mikedilger";
    repo = "gossip";
    tag = "v${finalAttrs.version}";
    hash = "sha256-nv/NMLAka62u0WzvHMEW9XBVXpg9T8bNJiUegS/oj48=";
  };

  postPatch = ''
    substituteInPlace $cargoDepsCopy/*/sdl2-sys-0.37.0/SDL/CMakeLists.txt \
      --replace-fail "cmake_minimum_required(VERSION 3.0.0)" "cmake_minimum_required(VERSION 3.0.0...3.5)" \
      --replace-fail "cmake_minimum_required(VERSION 3.4)" "cmake_minimum_required(VERSION 3.4...3.5)"
  '';

  nativeBuildInputs = [
    cmake
    git
    pkg-config
    rustPlatform.bindgenHook
    copyDesktopItems
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    wayland-scanner
  ];

  buildInputs = [
    SDL2
    ffmpeg_6
    fontconfig
    libGL
    libxkbcommon
    openssl
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    wayland
    libx11
    libxcb
    libxcursor
    libxi
    libxrandr
  ];

  cargoHash = "sha256-rE7SErOhl2fcmvLairq+mvdnbDIk1aPo3eYqwRx5kkA=";
  # Vendored SDL2 uses `bool` / `false` as identifiers, rejected by gcc 15's C23 default.
  env.NIX_CFLAGS_COMPILE = "-std=gnu17";
  # See https://github.com/mikedilger/gossip/blob/0.9/README.md.
  env.RUSTFLAGS = "--cfg tokio_unstable";
  # Tests rely on local files, so disable them. (I'm too lazy to patch it.)
  doCheck = false;

  postInstall = ''
    mkdir -p $out/logo
    cp $src/logo/gossip.png $out/logo/gossip.png
    mkdir -p $out/share/icons/hicolor/128x128/apps
    ln -s $out/logo/gossip.png $out/share/icons/hicolor/128x128/apps/gossip.png
  '';

  postFixup = lib.optionalString (!stdenv.hostPlatform.isDarwin) ''
    # We don't want the bundled libraries.
    rm -rf $out/lib

    patchelf $out/bin/gossip \
      --add-rpath ${
        lib.makeLibraryPath [
          SDL2
          libGL
          libxkbcommon
          wayland
        ]
      }
  '';

  # Some users might want to add "rustls-tls(-native)" for Rust TLS instead of OpenSSL.
  buildFeatures = [
    "video-ffmpeg"
    "lang-cjk"
  ];

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "Chat"
        "Network"
        "InstantMessaging"
      ];

      comment = finalAttrs.meta.description;
      desktopName = "Gossip";
      exec = "gossip";
      icon = "gossip";
      mimeTypes = [ "x-scheme-handler/nostr" ];
      name = "Gossip";
      startupWMClass = "gossip";
    })
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Desktop client for nostr, an open social media protocol";
    homepage = "https://github.com/mikedilger/gossip";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ msanft ];
    platforms = lib.platforms.unix;
    mainProgram = "gossip";
    downloadPage = "https://github.com/mikedilger/gossip/releases/tag/${finalAttrs.version}";
  };
})
