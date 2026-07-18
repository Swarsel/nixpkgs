{
  lib,
  fetchzip,
  stdenvNoCC,
}:

let
  fonts = {
    aegan = {
      version = "13.00";
      description = "Aegean";
      file = "Aegean.zip";
      hash = "sha256-3HmCqCMZLN6zF1N/EirQOPnHKTGHoc4aHKoZxFYTB34=";
    };

    aegyptus = {
      version = "13.00";
      description = "Egyptian Hieroglyphs, Coptic, Meroitic";
      file = "Aegyptus.zip";
      hash = "sha256-SSAK707xhpsUTq8tSBcrzNGunCYad58amtCqAWuevnY=";
    };

    akkadian = {
      version = "13.00";
      description = "Sumero-Akkadian Cuneiform";
      file = "Akkadian.zip";
      hash = "sha256-wXiDYyfujAs6fklOCqXq7Ms7wP5RbPlpNVwkUy7CV4k=";
    };

    assyrian = {
      version = "13.00";
      description = "Neo-Assyrian in Unicode with OpenType";
      file = "Assyrian.zip";
      hash = "sha256-CZj1sc89OexQ0INb7pbEu5GfE/w2E5JmhjT8cosoLSg=";
    };

    eemusic = {
      version = "13.00";
      description = "Byzantine Musical Notation in Unicode with OpenType";
      file = "EEMusic.zip";
      hash = "sha256-LxOcQOPEImw0wosxJotbOJRbe0qlK5dR+kazuhm99Kg=";
    };

    maya = {
      version = "13.00";
      description = "Maya Hieroglyphs";
      file = "Maya%20Hieroglyphs.zip";
      hash = "sha256-PAwF1lGqm6XVf4NQCA8AFLGU40N0Xsn5Q8x9ikHJDhY=";
    };

    symbola = {
      version = "13.00";
      description = "Basic Latin, Greek, Cyrillic and many Symbol blocks of Unicode";
      file = "Symbola.zip";
      hash = "sha256-TsHWmzkEyMa8JOZDyjvk7PDhm239oH/FNllizNFf398=";
    };

    textfonts = {
      version = "13.00";
      description = "Aroania, Anaktoria, Alexander, Avdira and Asea";
      file = "Textfonts.zip";
      hash = "sha256-7S3NiiyDvyYoDrLPt2z3P9bEEFOEZACv2sIHG1Tn6yI=";
    };

    unidings = {
      version = "13.00";
      description = "Glyphs and Icons for blocks of The Unicode Standard";
      file = "Unidings.zip";
      hash = "sha256-WUY+Ylphep6WuzqLQ3Owv+vK5Yuu/aAkn4GOFXL0uQY=";
    };
  };

  mkpkg =
    pname:
    {
      description,
      file,
      hash,
      version,
    }:
    stdenvNoCC.mkDerivation rec {
      inherit pname version;

      src = fetchzip {
        inherit hash;
        url = "https://web.archive.org/web/20221006174450/https://dn-works.com/wp-content/uploads/2020/UFAS-Fonts/${file}";
        stripRoot = false;
      };

      installPhase = ''
        runHook preInstall

        mkdir -p $out/share/{fonts/opentype,doc/${pname}}
        mv *.otf                -t "$out/share/fonts/opentype"
        mv *.{odt,ods,pdf,xlsx}       -t "$out/share/doc/${pname}"  || true  # install docs if any

        runHook postInstall
      '';

      meta = {
        inherit description;
        homepage = "https://web.archive.org/web/20221006174450/https://dn-works.com/ufas/";
        # see https://web.archive.org/web/20221006174450/https://dn-works.com/wp-content/uploads/2020/UFAS-Docs/License.pdf
        # quite draconian: non-commercial, no modifications,
        # no redistribution, "a single instantiation and no
        # network installation"
        license = lib.licenses.unfree;
      };
    };
in
lib.mapAttrs mkpkg fonts
