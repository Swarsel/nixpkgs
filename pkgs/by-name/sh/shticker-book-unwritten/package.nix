{
  lib,
  buildFHSEnv,
  callPackage,
}:
let

  shticker-book-unwritten-unwrapped = callPackage ./unwrapped.nix { };

in
buildFHSEnv {
  inherit (shticker-book-unwritten-unwrapped) version;
  pname = "shticker_book_unwritten";
  runScript = "shticker_book_unwritten";

  targetPkgs =
    pkgs: with pkgs; [
      alsa-lib
      libglvnd
      libpulseaudio
      shticker-book-unwritten-unwrapped
      libx11
      libxcursor
      libxext
    ];

  meta = {
    description = "Minimal CLI launcher for the Toontown Rewritten MMORPG";
    homepage = "https://github.com/JonathanHelianthicusDoe/shticker_book_unwritten";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.reedrw ];
    platforms = lib.platforms.linux;
    mainProgram = "shticker_book_unwritten";
  };
}
