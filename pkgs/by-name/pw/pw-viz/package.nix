{
  lib,
  fetchFromGitHub,
  expat,
  fontconfig,
  freetype,
  libGL,
  libx11,
  libxcursor,
  libxi,
  libxkbcommon,
  libxrandr,
  pipewire,
  pkg-config,
  rustPlatform,
  wayland,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "pw-viz";
  version = "0.3.0-2025-12-12";

  src = fetchFromGitHub {
    owner = "ax9d";
    repo = "pw-viz";
    rev = "b3fb0fb05059ba12f58d2a998842e13f0636cfed";
    hash = "sha256-TQJcIvCyWaDtJYcjZwclG5NtaUpDBugQQQc1txNzu88=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    expat
    fontconfig
    freetype
    libGL
    libxkbcommon
    pipewire
    rustPlatform.bindgenHook
    wayland
    libx11
    libxcursor
    libxi
    libxrandr
  ];

  cargoHash = "sha256-q1rgoEGQjzlXYcsfRUhrJi4w716a8D0x5SGl5fWM3ig=";

  postFixup = ''
    patchelf $out/bin/pw-viz \
      --add-rpath ${
        lib.makeLibraryPath [
          libGL
          libxkbcommon
          wayland
        ]
      }
  '';

  cargoPatches = [
    ./0001-fix-regenerate-Cargo.lock.patch
  ];

  meta = {
    description = "Simple and elegant pipewire graph editor";
    homepage = "https://github.com/ax9d/pw-viz";
    license = lib.licenses.gpl3Only;
    maintainers = [ lib.maintainers.progrm_jarvis ];
    platforms = lib.platforms.linux;
  };
})
