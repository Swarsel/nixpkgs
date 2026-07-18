{
  lib,
  stdenv,
  callPackage,
  installFonts,
}:
let
  src = (callPackage ./sources.nix { }).stable;
in
stdenv.mkDerivation {
  inherit (src) version;
  inherit src;
  pname = "wine-fonts";

  nativeBuildInputs = [
    installFonts
  ];

  sourceRoot = "wine-${src.version}/fonts";

  meta = {
    description = "Microsoft replacement fonts by the Wine project";
    homepage = "https://wiki.winehq.org/Create_Fonts";
    license = with lib.licenses; [ lgpl21Plus ];

    maintainers = with lib.maintainers; [
      avnik
      raskin
      bendlas
      johnazoidberg
    ];

    platforms = lib.platforms.all;
  };
}
