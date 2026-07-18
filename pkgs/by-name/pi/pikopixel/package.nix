{
  lib,
  fetchurl,
  clangStdenv,
  gnustep-back,
  wrapGNUstepAppsHook,
}:

clangStdenv.mkDerivation rec {
  pname = "pikopixel";
  version = "1.0-b10";

  src = fetchurl {
    url = "https://twilightedge.com/downloads/PikoPixel.Sources.${version}.tar.gz";
    sha256 = "1b27npgsan2nx1p581b9q2krx4506yyd6s34r4sf1r9x9adshm77";
  };

  nativeBuildInputs = [
    wrapGNUstepAppsHook
  ];

  buildInputs = [
    gnustep-back
  ];

  # Fix the Exec and Icon paths in the .desktop file, and save the file in the
  # correct place.
  # postInstall gets redefined in gnustep.make's builder.sh, so we use preFixup
  preFixup = ''
    mkdir -p $out/share/applications
    sed \
      -e "s@^Exec=.*\$@Exec=$out/bin/PikoPixel %F@" \
      -e "s@^Icon=.*/local@Icon=$out@" \
      PikoPixel.app/Resources/PikoPixel.desktop > $out/share/applications/PikoPixel.desktop
  '';

  sourceRoot = "PikoPixel.Sources.${version}/PikoPixel";

  meta = {
    description = "Application for drawing and editing pixel-art images";
    homepage = "https://twilightedge.com/mac/pikopixel/";
    license = lib.licenses.agpl3Plus;
    maintainers = with lib.maintainers; [ fgaz ];
    platforms = lib.platforms.all;
    mainProgram = "PikoPixel";
    downloadPage = "https://twilightedge.com/mac/pikopixel/";
  };
}
