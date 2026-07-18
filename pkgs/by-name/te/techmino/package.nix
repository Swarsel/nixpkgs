{
  lib,
  stdenv,
  fetchurl,
  callPackage,
  love,
  luajit,
  makeDesktopItem,
  makeWrapper,
  nix-update,
  writeShellScript,
  ccloader ? callPackage ./ccloader.nix { inherit libcoldclear luajit; },
  libcoldclear ? callPackage ./libcoldclear.nix { inherit ccloader; },
}:

let
  pname = "techmino";
  description = "Modern Tetris clone with many features";

  desktopItem = makeDesktopItem {
    categories = [ "Game" ];
    comment = description;
    desktopName = "Techmino";
    exec = "techmino";
    genericName = "Tetris Clone";

    icon = fetchurl {
      hash = "sha256-+j+8m2vwaWgHYSFL6urvTcB0vA+PCZ+FYJ22CNXfcSc=";
      name = "techmino.png";
      url = "https://github.com/26F-Studio/Techmino/assets/9590981/95981af1-f39a-47d9-bd99-a78ab767c08f";
    };

    name = pname;
  };
in

stdenv.mkDerivation rec {
  inherit pname;
  version = "0.17.21";

  src = fetchurl {
    url = "https://github.com/26F-Studio/Techmino/releases/download/v${version}/Techmino_Bare.love";
    hash = "sha256-8gMIyNP1FS52LnbpQ+G9XNtK3rQruzkMDRz7Gk9LZcQ=";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/games/lovegames
    cp $src $out/share/games/lovegames/techmino.love

    mkdir -p $out/bin
    makeWrapper ${lib.getExe love} $out/bin/techmino \
      --add-flags $out/share/games/lovegames/techmino.love \
      --suffix LUA_CPATH : ${ccloader}/lib/lua/${luajit.luaversion}/CCLoader.so

    mkdir -p $out/share/applications
    ln -s ${desktopItem}/share/applications/* $out/share/applications/

    runHook postInstall
  '';

  dontUnpack = true;

  passthru = {
    inherit ccloader libcoldclear;

    updateScript = writeShellScript "update-script.sh" ''
      if ${lib.getExe nix-update} techmino | grep "Packages updated"; then
        ${lib.getExe nix-update} techmino.ccloader
      fi
    '';
  };

  meta = {
    inherit description;
    homepage = "https://github.com/26F-Studio/Techmino/";
    license = lib.licenses.lgpl3;
    maintainers = with lib.maintainers; [ chayleaf ];
    platforms = love.meta.platforms;
    mainProgram = "techmino";
    downloadPage = "https://github.com/26F-Studio/Techmino/releases";
  };
}
