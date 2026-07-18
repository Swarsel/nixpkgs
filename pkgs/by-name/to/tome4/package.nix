{
  lib,
  stdenv,
  fetchFromGitLab,
  SDL2,
  SDL2_image,
  SDL2_ttf,
  copyDesktopItems,
  fetchpatch2,
  libGLU,
  libpng,
  libvorbis,
  libx11,
  makeDesktopItem,
  makeWrapper,
  nix-update-script,
  openal,
  premake4,
  xorgproto,
}:

let
  sdlInputs = [
    SDL2
    SDL2_ttf
    SDL2_image
  ];
in

stdenv.mkDerivation (finalAttrs: {
  pname = "tome4";
  version = "1.7.6";

  # Official source according to https://te4.org/wiki/How_to_compile
  src = fetchFromGitLab {
    owner = "tome";
    repo = "t-engine4";
    tag = "tome-${finalAttrs.version}";
    hash = "sha256-v0YPbmaOqKYgFkOe/X0FCirucrMo2UGAyhZ7MFj+nsU=";
    domain = "git.net-core.org";
  };

  patches = [
    # https://forums.te4.org/viewtopic.php?f=69&t=39859&p=168681&hilit=luaopen_shaders#p168681
    (fetchpatch2 {
      hash = "sha256-g47N/bi2/DDKqaEkfTaGp9ItS57QVnObzMDWXqrCjWE=";
      url = "https://gist.githubusercontent.com/hasufell/cb3b10f834e891d90f83/raw/cb4adda13868f6b94585575db4f8df70877ae45a/tome4-1.1.3-fix-implicit-declaration.patch";
    })
    # unistd required for execv
    ./0001-web-missing-include.patch
    # unistd required for read and close
    ./0002-zlib-missing-include.patch
    ./0003-incompatible-pointer-types.patch
    # C23 requires stdbool for an actual proper boolean type instead of `char'
    ./0004-fix-build-with-C23.patch
  ];

  nativeBuildInputs = [
    copyDesktopItems
    makeWrapper
    premake4
  ];

  # tome4 vendors quite a few libraries so someone might want to look
  # into avoiding that...
  buildInputs = [
    libGLU
    openal
    libpng
    libvorbis
    libx11
    xorgproto
  ]
  ++ sdlInputs;

  makeFlags = [ "config=release" ];

  env = {
    NIX_CFLAGS_COMPILE =
      lib.concatMapStringsSep " " (i: "-I${lib.getInclude i}/include/SDL2") sdlInputs
      + " "
      + lib.concatMapStringsSep " " (i: "-I${lib.getInclude i}") finalAttrs.buildInputs;

    NIX_CFLAGS_LINK = lib.concatMapStringsSep " " (i: "-L${lib.getLib i}/lib") finalAttrs.buildInputs;
  };

  # The wrapper needs to cd into the correct directory as tome4's detection of
  # the game asset root directory is faulty.
  installPhase = ''
    runHook preInstall

    dir=$out/share/tome4

    install -Dm755 t-engine $dir/t-engine
    cp -r bootstrap game $dir
    makeWrapper $dir/t-engine $out/bin/tome4 \
      --chdir "$dir"

    install -Dm644 game/engines/default/data/gfx/te4-icon.png -t $out/share/icons/hicolor/64x64

    install -Dm644 -t $out/share/doc/tome4 CONTRIBUTING COPYING COPYING-MEDIA CREDITS

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "Game"
        "RolePlaying"
      ];

      comment = "An open-source, single-player, role-playing roguelike game set in the world of Eyal.";
      desktopName = "Tales of Maj'Eyal";
      exec = "tome4";
      genericName = "2D roguelike RPG";
      icon = "te4-icon";
      name = "tome4";
      type = "Application";
    })
  ];

  # disable parallel building as it caused sporadic build failures
  enableParallelBuilding = false;

  prePatch = ''
    # http://forums.te4.org/viewtopic.php?f=42&t=49478&view=next#p234354
    substituteInPlace src/tgl.h \
      --replace-fail "#include <GL/glext.h>" ""
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "tome-(.*)"
    ];
  };

  meta = {
    description = "Tales of Maj'eyal (rogue-like game)";
    homepage = "https://te4.org/";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ peterhoeg ];

    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];

    mainProgram = "tome4";
  };
})
