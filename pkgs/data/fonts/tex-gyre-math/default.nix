{
  lib,
  stdenv,
  fetchzip,
}:

let
  variants = {
    bonum = {
      version = "1.005";
      displayName = "Bonum";
      outputHash = "1zjaxkzidqmxakh9d61n0by9mi8hrmir45jppjj6hzwhm3rvknff";
      sha256 = "1b6x7siypyxp1lhq7xxdqafwbn6p2p3xm3jb38q999sv8cgslxz8";
    };

    pagella = {
      version = "1.632";
      displayName = "Pagella";
      outputHash = "0wz2n1dpx9b8a0qgqy8vl712fxhi87mhcda281xaad62chndwf6k";
      sha256 = "0f4cgq9w0lc1fbcbfqiv19mdhivbsscl13jmb0ln685641ci2sjr";
    };

    schola = {
      version = "1.533";
      displayName = "Schola";
      outputHash = "0jk4bpxki95a9lmfj4cgpnv1jwlkh8qixbkf498n1x7hkaz03f5n";
      sha256 = "0caqgkz7gz700h5a1mai0gq8hv7skrgs5nnrs1f7zw1mb9g53ya9";
    };

    termes = {
      version = "1.543";
      displayName = "Termes";
      outputHash = "0pa433cgshlypbyrrlp3qq0wg972rngcp37pr8pxdfshgz13q1mm";
      sha256 = "10ayqfpryfn1l35hy0vwyjzw3a6mfsnzgf78vsnccgk2gz1g9vhz";
    };
  };

  mkVariant =
    variant:
    {
      displayName,
      outputHash,
      sha256,
      version,
    }:
    let
      dotless_version = builtins.replaceStrings [ "." ] [ "" ] version;
    in
    stdenv.mkDerivation rec {
      inherit version;
      inherit outputHash;
      pname = "tex-gyre-${variant}-math";

      src = fetchzip {
        inherit sha256;
        url = "https://www.gust.org.pl/projects/e-foundry/tg-math/download/texgyre${variant}-math-${dotless_version}.zip";
      };

      installPhase = ''
        install -m444 -Dt $out/share/fonts/opentype opentype/*.otf
        install -m444 -Dt $out/share/doc/${pname}-${version}    doc/*.txt
      '';

      outputHashAlgo = "sha256";
      outputHashMode = "recursive";

      meta = {
        longDescription = ''
          TeX Gyre ${displayName} Math is a math companion for the TeX Gyre
          ${displayName} family of fonts (see
          http://www.gust.org.pl/projects/e-foundry/tex-gyre/) in the OpenType format.
        '';

        homepage = "http://www.gust.org.pl/projects/e-foundry/tg-math";
        # "The TeX Gyre Math fonts are licensed under the GUST Font License (GFL),
        # which is a free license, legally equivalent to the LaTeX Project Public
        # License (LPPL), version 1.3c or later." - GUST website
        license = lib.licenses.lppl13c;
        maintainers = with lib.maintainers; [ siddharthist ];
        platforms = lib.platforms.all;
      };
    };
in
lib.mapAttrs mkVariant variants
