{
  lib,
  fetchFromGitHub,
  copyDesktopItems,
  icoutils,
  libx11,
  libxcursor,
  libxi,
  libxkbcommon,
  luajit,
  makeDesktopItem,
  makeWrapper,
  pkg-config,
  rustPlatform,
  vulkan-loader,
  wayland,
  zlib,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "rusty-path-of-building";
  version = "0.2.18";

  src = fetchFromGitHub {
    owner = "meehl";
    repo = "rusty-path-of-building";
    tag = "v${finalAttrs.version}";
    hash = "sha256-9YHXTUtTJO3GPf+NqASEkxf+a94doBGTjLyYruuxRg4=";
  };

  nativeBuildInputs = [
    pkg-config
    icoutils
    copyDesktopItems
    makeWrapper
  ];

  buildInputs = [
    luajit
    luajit.pkgs.lua-curl
    luajit.pkgs.luautf8
    luajit.pkgs.luasocket

    # this is weird and vendored and should probably stay that way
    (luajit.pkgs.buildLuaPackage {
      inherit (finalAttrs) version;
      pname = "lzip";
      src = "${finalAttrs.src}/lua/libs/lzip";
      nativeBuildInputs = [ pkg-config ];
      buildInputs = [ zlib ];
      installFlags = [ "LUA_CMOD=$(out)/lib/lua/${luajit.luaversion}" ];
    })

    wayland
  ];

  cargoHash = "sha256-8J1tZukp/Cchxj0QireOhu/eZd0N7uZa86XDLTBmHQk=";

  postInstall = ''
    install -Dm444 assets/icon.png $out/share/icons/hicolor/256x256/apps/path-of-building.png
  '';

  postFixup = ''
    patchelf $out/bin/rusty-path-of-building \
      --add-rpath ${
        lib.makeLibraryPath [
          libxkbcommon
          vulkan-loader
          wayland
          libx11
          libxcursor
          libxi
        ]
      }

    wrapProgram $out/bin/rusty-path-of-building \
      --set LUA_PATH "$LUA_PATH" \
      --set LUA_CPATH "$LUA_CPATH"
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [ "Game" ];
      comment = "Offline build planner for Path of Exile";
      desktopName = "Path of Building";
      exec = "rusty-path-of-building poe1";
      icon = "path-of-building";

      keywords = [
        "poe"
        "pob"
        "pobc"
        "path"
        "exile"
      ];

      name = "rusty-path-of-building-1";
      terminal = false;
      type = "Application";
    })
    (makeDesktopItem {
      categories = [ "Game" ];
      comment = "Offline build planner for Path of Exile 2";
      desktopName = "Path of Building 2";
      exec = "rusty-path-of-building poe2";
      icon = "path-of-building";

      keywords = [
        "poe"
        "pob"
        "pobc"
        "path"
        "exile"
      ];

      name = "rusty-path-of-building-2";
      terminal = false;
      type = "Application";
    })
  ];

  meta = {
    description = "A cross-platform runtime for Path of Building and Path of Building 2.";
    homepage = "https://github.com/meehl/rusty-path-of-building";
    changelog = "https://github.com/meehl/rusty-path-of-building/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      k900
      cholli
    ];

    mainProgram = "rusty-path-of-building";
  };
})
