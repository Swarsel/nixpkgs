{
  lib,
  stdenv,
  fetchFromGitHub,
  fontforge,
  python3,
}:
let
  inherit (python3.pkgs) fonttools;

  commonNativeBuildInputs = [
    fontforge
    python3
  ];
  common =
    {
      docsToInstall,
      nativeBuildInputs,
      repo,
      sha256,
      version,
      postPatch ? null,
    }:
    stdenv.mkDerivation rec {
      inherit version;
      inherit nativeBuildInputs postPatch;
      pname = "liberation-fonts";

      src = fetchFromGitHub {
        inherit repo sha256;
        owner = "liberationfonts";
        rev = version;
      };

      installPhase = ''
        find . -name '*.ttf' -exec install -m444 -Dt $out/share/fonts/truetype {} \;

        for i in ${toString docsToInstall}; do
          # not all docs exist in all versions
          install -m444 -Dt $out/share/doc/${pname}-${version} $i || true
        done
      '';

      meta = {
        description = "Liberation Fonts, replacements for Times New Roman, Arial, and Courier New";

        longDescription = ''
          The Liberation Fonts are intended to be replacements for the three most
          commonly used fonts on Microsoft systems: Times New Roman, Arial, and
          Courier New. Since 2012 they are based on croscore fonts.

          There are three sets: Sans (a substitute for Arial, Albany, Helvetica,
          Nimbus Sans L, and Bitstream Vera Sans), Serif (a substitute for Times
          New Roman, Thorndale, Nimbus Roman, and Bitstream Vera Serif) and Mono
          (a substitute for Courier New, Cumberland, Courier, Nimbus Mono L, and
          Bitstream Vera Sans Mono).
        '';

        homepage = "https://github.com/liberationfonts";
        license = lib.licenses.ofl;
        maintainers = with lib.maintainers; [ raskin ];
      };
    };
in
{
  liberation_ttf_v1 = common {
    version = "1.07.5";
    nativeBuildInputs = commonNativeBuildInputs;

    docsToInstall = [
      "AUTHORS"
      "ChangeLog"
      "COPYING"
      "License.txt"
      "README"
    ];

    repo = "liberation-1.7-fonts";
    sha256 = "1ffl10mf78hx598sy9qr5m6q2b8n3mpnsj73bwixnd4985gsz56v";
  };

  liberation_ttf_v2 = common {
    version = "2.1.5";

    postPatch = ''
      substituteInPlace scripts/setisFixedPitch-fonttools.py --replace \
        'font = ttLib.TTFont(fontfile)' \
        'font = ttLib.TTFont(fontfile, recalcTimestamp=False)'
    '';

    nativeBuildInputs = commonNativeBuildInputs ++ [ fonttools ];

    docsToInstall = [
      "AUTHORS"
      "ChangeLog"
      "LICENSE"
      "README.md"
    ];

    repo = "liberation-fonts";
    sha256 = "Wg1uoD2k/69Wn6XU+7wHqf2KO/bt4y7pwgmG7+IUh4Q=";
  };
}
