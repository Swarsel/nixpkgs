{
  lib,
  jazz2,
  runCommandLocal,
}:

runCommandLocal "jazz2-content"
  {
    inherit (jazz2) version src;
    pname = "jazz2-content";

    meta = (removeAttrs jazz2.meta [ "mainProgram" ]) // {
      description = "Assets needed for jazz2";
      platforms = lib.platforms.all;
    };
  }
  ''
    cp -r $src/Content $out
  ''
