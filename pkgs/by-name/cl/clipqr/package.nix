{
  lib,
  fetchFromGitLab,
  buildGoModule,
  copyDesktopItems,
  libGL,
  libdecor,
  libgbm,
  libx11,
  libxcursor,
  libxext,
  libxi,
  libxinerama,
  libxkbcommon,
  libxrandr,
  libxxf86vm,
  makeDesktopItem,
  makeWrapper,
  pkg-config,
  wayland,
  wl-clipboard,
}:

buildGoModule (finalAttrs: {
  pname = "clipqr";
  version = "1.4.0";

  src = fetchFromGitLab {
    owner = "imatt-foss";
    repo = "clipqr";
    rev = "v${finalAttrs.version}";
    hash = "sha256-DC6zc1Qe/z7ihuvdawb8bj5MefYGgt7HAV5dWTjeHZc=";
  };

  nativeBuildInputs = [
    copyDesktopItems
    makeWrapper
    pkg-config
  ];

  buildInputs = [
    libGL
    libgbm
    libx11
    libxcursor
    libxext
    libxi
    libxinerama
    libxkbcommon
    libxrandr
    libxxf86vm
    wayland
  ];

  vendorHash = "sha256-MrXMbavff6CEKVbL+Mx8hICYB9sZQcvAhnu2X4sVvVw=";

  postInstall = ''
    install -Dm644 icon.svg $out/share/icons/hicolor/scalable/apps/clipqr.svg

    wrapProgram $out/bin/clipqr \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ libdecor ]} \
      --prefix PATH : ${lib.makeBinPath [ wl-clipboard ]}
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [ "Utility" ];
      comment = "Scan QR codes on screen and from camera";
      desktopName = "ClipQR";
      exec = "clipqr";
      genericName = "ClipQR";
      icon = "clipqr";
      name = "ClipQR";
    })
  ];

  ldflags = [
    "-s"
    "-w"
  ];

  tags = [ "wayland" ];

  meta = {
    description = "Scan QR codes on screen and from camera, the result is in your clipboard";
    homepage = "https://gitlab.com/imatt-foss/clipqr";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ MatthieuBarthel ];
    platforms = lib.platforms.linux;
    mainProgram = "clipqr";
  };
})
