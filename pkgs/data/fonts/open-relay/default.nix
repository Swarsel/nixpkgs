{
  lib,
  fetchFromGitHub,
  stdenvNoCC,
}:

let
  mkOpenRelayTypeface =
    name:
    { directory, meta }:
    stdenvNoCC.mkDerivation (finalAttrs: {
      pname = "open-relay-${name}";
      version = "2026-04-12";

      src = fetchFromGitHub {
        owner = "kreativekorp";
        repo = "open-relay";
        tag = finalAttrs.version;
        hash = "sha256-UI3JP/5Os7xWB07dwlEpWuDMG1awpsOr0itmZpxGtyg=";
      };

      installPhase = ''
        runHook preInstall


        install -D -m444 -t "$out/share/fonts/truetype" "${directory}/"*.ttf
        install -D -m644 -t "$out/share/doc/${finalAttrs.pname}-${finalAttrs.version}" "${directory}/OFL.txt"

        runHook postInstall
      '';

      meta = {
        description = "Free and open source fonts from Kreative Software";
        homepage = "https://www.kreativekorp.com/software/fonts/index.shtml";
        license = lib.licenses.ofl;

        maintainers = with lib.maintainers; [
          linus
          toastal
        ];

        platforms = lib.platforms.all;
      }
      // meta;
    });
in
lib.mapAttrs mkOpenRelayTypeface {
  constructium = {
    directory = "Constructium";

    meta = {
      description = "Fork of SIL Gentium designed specifically to support constructed scripts as encoded in the Under-ConScript Unicode Registry";

      longDescription = ''
        Constructium is a fork of SIL Gentium designed specifically to support
        constructed scripts as encoded in the Under-ConScript Unicode Registry.
        It is ideal for mixed Latin, Greek, Cyrillic, IPA, and conlang text in
        web sites and documents.
      '';

      homepage = "https://www.kreativekorp.com/software/fonts/constructium/";
    };
  };

  fairfax = {
    directory = "Fairfax";

    meta = {
      description = "6×12 bitmap font supporting many Unicode blocks & scripts as well as constructed scripts";

      longDescription = ''
        Fairfax is a 6×12 bitmap font for terminals, text editors, IDEs, etc. It
        supports many scripts and a large number of Unicode blocks as well as
        constructed scripts as encoded in the Under-ConScript Unicode Registry,
        pseudographics and semigraphics, and tons of private use characters. It
        has been superceded by Fairfax HD but is still maintained.
      '';

      homepage = "https://www.kreativekorp.com/software/fonts/fairfax/";
    };
  };

  fairfax-hd = {
    directory = "FairfaxHD";

    meta = {
      description = "Halfwidth scalable monospace font supporting many Unicode blocks & script as well as constructed scripts";

      longDescription = ''
        Fairfax HD is a halfwidth scalable monospace font for terminals, text
        editors, IDEs, etc. It supports many scripts and a large number of
        Unicode blocks as well as constructed scripts as encoded in the
        Under-ConScript Unicode Registry, pseudographics and semigraphics, and
        tons of private use characters.
      '';

      homepage = "https://www.kreativekorp.com/software/fonts/fairfaxhd/";
    };
  };

  kreative-square = {
    directory = "KreativeSquare";

    meta = {
      description = "Fullwidth scalable monospace font designed specifically to support pseudographics, semigraphics, and private use characters";
      homepage = "https://www.kreativekorp.com/software/fonts/ksquare/";
    };
  };
}
