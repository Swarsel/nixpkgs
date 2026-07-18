{
  lib,
  fetchFromGitHub,
  alsa-lib,
  fetchpatch,
  ffmpeg_7,
  libx11,
  libxcursor,
  libxi,
  libxkbcommon,
  libxrender,
  makeWrapper,
  pkg-config,
  rustPlatform,
  vulkan-loader,
  wayland,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "neothesia";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "PolyMeilex";
    repo = "Neothesia";
    tag = "v${finalAttrs.version}";
    hash = "sha256-5DuyWuDJ08S12C3OWhC9mLhQvPCfWMdJCRUOWtKq/+k=";
  };

  patches = [
    (fetchpatch {
      hash = "sha256-A7GuaEHIfSFrvS1SCBWGCuh3rvb2gaaw8dQ970f6u2Y=";
      url = "https://github.com/PolyMeilex/Neothesia/commit/c450689134e5e767293ae9a4878a0396e585259b.patch";
    })
  ];

  nativeBuildInputs = [
    pkg-config
    makeWrapper
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    ffmpeg_7
    alsa-lib
  ];

  cargoHash = "sha256-gX9DlgPgrM8KukX3auxbBKpJq7QG4+kRhHSUk3eQjAQ=";

  postInstall = ''
    wrapProgram $out/bin/neothesia --prefix LD_LIBRARY_PATH : "${
      lib.makeLibraryPath [
        wayland
        libxkbcommon
        vulkan-loader
        libx11
        libxcursor
        libxi
        libxrender
      ]
    }"

    install -Dm 644 flatpak/com.github.polymeilex.neothesia.desktop $out/share/applications/com.github.polymeilex.neothesia.desktop
    install -Dm 644 flatpak/com.github.polymeilex.neothesia.png $out/share/icons/hicolor/256x256/apps/com.github.polymeilex.neothesia.png
    install -Dm 644 default.sf2 $out/share/neothesia/default.sf2
  '';

  cargoBuildFlags = [
    "-p neothesia -p neothesia-cli"
  ];

  meta = {
    description = "Flashy Synthesia Like Software For Linux, Windows and macOS";
    homepage = "https://github.com/PolyMeilex/Neothesia";
    license = lib.licenses.gpl3;

    maintainers = [
      lib.maintainers.naxdy
    ];

    platforms = lib.platforms.linux;
    mainProgram = "neothesia";
  };
})
