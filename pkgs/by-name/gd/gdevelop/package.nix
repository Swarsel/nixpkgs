{
  lib,
  stdenv,
  callPackage,
}:
let
  version = "5.6.269";
  pname = "gdevelop";
  meta = {
    description = "Graphical Game Development Studio";
    homepage = "https://gdevelop.io/";
    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];

    maintainers = with lib.maintainers; [
      tombert
      matteopacini
    ];

    platforms = [ "x86_64-linux" ] ++ lib.platforms.darwin;
    mainProgram = "gdevelop";
    downloadPage = "https://github.com/4ian/GDevelop/releases";
  };
  passthru.updateScript = ./update.sh;
in
if stdenv.hostPlatform.isDarwin then
  callPackage ./darwin.nix {
    inherit
      pname
      version
      meta
      passthru
      ;
  }
else
  callPackage ./linux.nix {
    inherit
      pname
      version
      meta
      passthru
      ;
  }
