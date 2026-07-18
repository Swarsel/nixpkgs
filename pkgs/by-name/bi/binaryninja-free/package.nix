{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  copyDesktopItems,
  dbus,
  fontconfig,
  freetype,
  libGLU,
  libxcb-image,
  libxcb-keysyms,
  libxcb-render-util,
  libxcb-wm,
  libxkbcommon,
  libxml2,
  makeDesktopItem,
  unzip,
  wayland,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "binaryninja-free";
  version = "5.2.8722";

  src = fetchurl {
    url = "https://github.com/Vector35/binaryninja-api/releases/download/stable/${finalAttrs.version}/binaryninja_free_linux.zip";
    hash = "sha256-YlBr/Cdjev7LWY/VsKgv/i3zHj4YR49RX69zmhhie7U=";
  };

  nativeBuildInputs = [
    unzip
    autoPatchelfHook
    copyDesktopItems
  ];

  buildInputs = [
    dbus
    fontconfig
    freetype
    libGLU
    libxkbcommon
    stdenv.cc.cc.lib
    wayland
    libxcb-image
    libxcb-keysyms
    libxcb-render-util
    libxcb-wm
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/
    cp -R . $out/

    mkdir $out/bin
    ln -s $out/binaryninja $out/bin/binaryninja

    install -Dm644 ${finalAttrs.icon} $out/share/icons/hicolor/256x256/apps/binaryninja.png

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [ "Utility" ];
      comment = "A Reverse Engineering Platform";
      desktopName = "Binary Ninja Free";
      exec = "binaryninja";
      icon = "binaryninja";

      mimeTypes = [
        "application/x-binaryninja"
        "x-scheme-handler/binaryninja"
      ];

      name = "com.vector35.binaryninja";
    })
  ];

  icon = fetchurl {
    hash = "sha256-TzGAAefTknnOBj70IHe64D6VwRKqIDpL4+o9kTw0Mn4=";
    url = "https://raw.githubusercontent.com/Vector35/binaryninja-api/448f40be71dffa86a6581c3696627ccc1bdf74f2/docs/img/logo.png";
  };

  meta = {
    description = "Interactive decompiler, disassembler, debugger";
    homepage = "https://binary.ninja/";

    changelog = "https://binary.ninja/changelog/#${
      lib.replaceStrings [ "." ] [ "-" ] finalAttrs.version
    }";

    license = {
      free = false;
      fullName = "Binary Ninja Free Software License";
      url = "https://docs.binary.ninja/about/license.html#free-license";
    };

    maintainers = with lib.maintainers; [
      scoder12
      timschumi
    ];

    platforms = [ "x86_64-linux" ];
    mainProgram = "binaryninja";
  };
})
