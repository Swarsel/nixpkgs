{
  lib,
  stdenv,
  fetchgit,
}:

let
  mkDictFromChromium =
    {
      dictFileName,
      shortDescription,
      shortName,
    }:
    stdenv.mkDerivation {
      pname = "hunspell-dict-${shortName}-chromium";
      version = "145.0.7632.45";

      src = fetchgit {
        url = "https://chromium.googlesource.com/chromium/deps/hunspell_dictionaries";
        rev = "cccf64a8acc951afe3f47fee023908e55699bc58";
        hash = "sha256-mYDPXa64IOKLMNiBiMqDrQMR7gDPI+vdyVc+M7E+ddc=";
      };

      installPhase = ''
        cp ${dictFileName} $out
      '';

      dontBuild = true;

      passthru = {
        # As chromium needs the exact filename in ~/.config/chromium/Dictionaries,
        # this value needs to be known to tools using the package if they want to
        # link the file correctly.
        inherit dictFileName;
        updateScript = ./update-chromium-dictionaries.py;
      };

      meta = {
        description = "Chromium compatible hunspell dictionary for ${shortDescription}";

        longDescription = ''
          Humspell directories in Chromium's custom bdic format

          See https://www.chromium.org/developers/how-tos/editing-the-spell-checking-dictionaries/
        '';

        homepage = "https://chromium.googlesource.com/chromium/deps/hunspell_dictionaries/";

        license = with lib.licenses; [
          gpl2
          lgpl21
          mpl11
          lgpl3
        ];

        maintainers = with lib.maintainers; [ networkexception ];
        platforms = lib.platforms.all;
      };
    };
in
rec {

  inherit mkDictFromChromium;

  de-de = mkDictFromChromium {
    dictFileName = "de-DE-3-0.bdic";
    shortDescription = "German (Germany)";
    shortName = "de-de";
  };

  # GERMAN
  de_DE = de-de;

  en-gb = mkDictFromChromium {
    dictFileName = "en-GB-10-1.bdic";
    shortDescription = "English (United Kingdom)";
    shortName = "en-gb";
  };

  en-us = mkDictFromChromium {
    dictFileName = "en-US-10-1.bdic";
    shortDescription = "English (United States)";
    shortName = "en-us";
  };

  en_GB = en-us;
  # ENGLISH
  en_US = en-us;

  fr-fr = mkDictFromChromium {
    dictFileName = "fr-FR-3-0.bdic";
    shortDescription = "French (France)";
    shortName = "fr-fr";
  };

  # FRENCH
  fr_FR = fr-fr;

  sv-se = mkDictFromChromium {
    dictFileName = "sv-SE-3-0.bdic";
    shortDescription = "Swedish (Sweden)";
    shortName = "sv-se";
  };

  # SWEDISH
  sv_SE = sv-se;
}
