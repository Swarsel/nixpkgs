{
  lib,
  fetchurl,
  installFonts,
  stdenvNoCC,
  unzip,
}:

let
  makeSuperOTC =
    {
      description,
      family,
      hash,
      rev,
      prefix ? "",
      zip ? "",
    }:
    let
      Family = lib.toUpper (lib.substring 0 1 family) + lib.substring 1 (lib.stringLength family) family;
    in
    stdenvNoCC.mkDerivation {
      pname = "source-han-${family}";
      version = lib.removeSuffix "R" rev;

      src = fetchurl {
        inherit hash;
        url = "https://github.com/adobe-fonts/source-han-${family}/releases/download/${rev}/${prefix}SourceHan${Family}.ttc${zip}";
      };

      strictDeps = true;
      nativeBuildInputs = [ installFonts ] ++ lib.optionals (zip == ".zip") [ unzip ];
      __structuredAttrs = true;

      unpackPhase =
        lib.optionalString (zip == "") ''
          cp $src SourceHan${Family}.ttc${zip}
        ''
        + lib.optionalString (zip == ".zip") ''
          unzip $src
        '';

      meta = {
        description = "Open source Pan-CJK ${description} typeface";
        homepage = "https://github.com/adobe-fonts/source-han-${family}";
        license = lib.licenses.ofl;

        maintainers = with lib.maintainers; [
          taku0
          emily
        ];
      };
    };

  makeVariable =
    {
      family,
      format,
      hash,
      version,
    }:
    let
      Family = lib.toUpper (lib.substring 0 1 family) + lib.substring 1 (lib.stringLength family) family;
    in
    fetchurl {
      inherit version hash;
      pname = "source-han-${family}-vf-${format}";
      downloadToTemp = true;
      postFetch = "install -Dm444 $downloadedFile $out/share/fonts/variable/SourceHan${Family}-VF.${format}.ttc";
      recursiveHash = true;
      url = "https://raw.githubusercontent.com/adobe-fonts/source-han-${family}/${version}R/Variable/OTC/SourceHan${Family}-VF.${format}.ttc";

      meta = {
        description = "Open source Pan-CJK ${Family} typeface";
        homepage = "https://github.com/adobe-fonts/source-han-${family}";
        license = lib.licenses.ofl;

        maintainers = with lib.maintainers; [
          taku0
          emily
        ];
      };
    };
in
{
  source-han-mono = makeSuperOTC {
    description = "monospaced";
    family = "mono";
    hash = "sha256-DBkkSN6QhI8R64M2h2iDqaNtxluJZeSJYAz8x6ZzWME=";
    rev = "1.002";
  };

  source-han-sans = makeSuperOTC {
    description = "sans-serif";
    family = "sans";
    hash = "sha256-oCTPF1lJSEfNR6rkN5vLPcUwAXxwnz9QPuDtkY3ZKVI=";
    prefix = "01_";
    rev = "2.005R";
    zip = ".zip";
  };

  source-han-sans-vf-otf = makeVariable {
    version = "2.005";
    family = "sans";
    format = "otf";
    hash = "sha256-7/THncqTE6IpPezcX14eYRRC8WR/xPv0XjfOPEfF8aU=";
  };

  source-han-sans-vf-ttf = makeVariable {
    version = "2.005";
    family = "sans";
    format = "ttf";
    hash = "sha256-CL5kjZzCiNvdcwiFflTlarINpeYxvuqZH+4ayiIQdD8=";
  };

  source-han-serif = makeSuperOTC {
    description = "serif";
    family = "serif";
    hash = "sha256-buaJq1eJSuNa9gSnPpXDcr2gMGYQ/6F5pHCOjNR6eV8=";
    prefix = "01_";
    rev = "2.003R";
    zip = ".zip";
  };

  source-han-serif-vf-otf = makeVariable {
    version = "2.003";
    family = "serif";
    format = "otf";
    hash = "sha256-a6295Ukha9QY5ByMr2FUy13j5gZ1itnezvfJWmJjqt0=";
  };

  source-han-serif-vf-ttf = makeVariable {
    version = "2.003";
    family = "serif";
    format = "ttf";
    hash = "sha256-F+FUQunfyAEBVV10lZxC3dzGTWhHgHzpTO8CjC3n4WY=";
  };
}
