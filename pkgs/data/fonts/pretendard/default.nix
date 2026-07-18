{
  lib,
  fetchzip,
  stdenvNoCC,
}:

let
  version = "1.3.9";

  mkPretendard =
    {
      hash,
      pname,
      typeface,
    }:
    stdenvNoCC.mkDerivation {
      inherit pname version;

      src = fetchzip {
        inherit hash;
        url = "https://github.com/orioncactus/pretendard/releases/download/v${version}/${typeface}-${version}.zip";
        stripRoot = false;
      };

      installPhase = ''
        runHook preInstall

        install -Dm644 public/static/*.otf -t $out/share/fonts/opentype

        runHook postInstall
      '';

      meta = {
        description = "Alternative font to system-ui for all platforms";
        homepage = "https://github.com/orioncactus/pretendard";
        license = lib.licenses.ofl;
        maintainers = with lib.maintainers; [ sudosubin ];
        platforms = lib.platforms.all;
      };
    };

in
{
  pretendard = mkPretendard {
    pname = "pretendard";
    hash = "sha256-n7RQApffpL/8ojHcZbdxyanl9Tlc8HP8kxLFBdArUfY=";
    typeface = "Pretendard";
  };

  pretendard-gov = mkPretendard {
    pname = "pretendard-gov";
    hash = "sha256-qoDUBOmrk6WPKQgnapThfKC01xWup+HN82hcoIjEe0M=";
    typeface = "PretendardGOV";
  };

  pretendard-jp = mkPretendard {
    pname = "pretendard-jp";
    hash = "sha256-1nTk1LPoRSfSDgDuGWkcs6RRIY4ZOqDBPMsxezMos6Q=";
    typeface = "PretendardJP";
  };

  pretendard-std = mkPretendard {
    pname = "pretendard-std";
    hash = "sha256-gkYqqxSICmSIrBuPRzBaOlGGM/rJU1z7FiFvu9RhK5s=";
    typeface = "PretendardStd";
  };
}
