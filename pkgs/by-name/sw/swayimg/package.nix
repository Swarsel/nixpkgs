{
  lib,
  stdenv,
  fetchFromGitHub,
  bash-completion,
  exiv2,
  fontconfig,
  giflib,
  json_c,
  libavif,
  libdrm,
  libheif,
  libjpeg,
  libjxl,
  libpng,
  libraw,
  librsvg,
  libsixel,
  libtiff,
  libwebp,
  libxkbcommon,
  luajit,
  meson,
  ninja,
  nix-update-script,
  openexr,
  openjpeg,
  pkg-config,
  testers,
  wayland,
  wayland-protocols,
  wayland-scanner,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "swayimg";
  version = "5.4";

  src = fetchFromGitHub {
    owner = "artemsen";
    repo = "swayimg";
    tag = "v${finalAttrs.version}";
    hash = "sha256-PB+EufDpz5Rc6hKO/ish7HdGaEZtxmrtYqnmR+ZpFDY=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    wayland-scanner
  ];

  buildInputs = [
    bash-completion
    wayland
    wayland-protocols
    json_c
    libxkbcommon
    exiv2
    fontconfig
    giflib
    libheif
    libjpeg
    libwebp
    libtiff
    librsvg
    libpng
    libjxl
    libavif
    libsixel
    libraw
    libdrm
    luajit
    openexr
    openjpeg
  ];

  mesonFlags = [
    (lib.mesonOption "version" finalAttrs.version)
  ];

  depsBuildBuild = [
    pkg-config
  ];

  passthru = {
    tests.version = testers.testVersion {
      package = finalAttrs.finalPackage;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Image viewer for Sway/Wayland";
    homepage = "https://github.com/artemsen/swayimg";
    changelog = "https://github.com/artemsen/swayimg/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      matthewcroughan
      Gliczy
    ];

    platforms = lib.platforms.linux;
    mainProgram = "swayimg";
  };
})
