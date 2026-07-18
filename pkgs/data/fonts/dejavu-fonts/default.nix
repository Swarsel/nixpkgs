{
  lib,
  stdenv,
  fetchFromGitHub,
  fontforge,
  perl,
  perlPackages,
}:

let
  version = "2.37";

  meta = {
    description = "Typeface family based on the Bitstream Vera fonts";

    longDescription = ''
      The DejaVu fonts are TrueType fonts based on the BitStream Vera fonts,
      providing more styles and with greater coverage of Unicode.

      This package includes DejaVu Sans, DejaVu Serif, DejaVu Sans Mono, and
      the DejaVu Math TeX Gyre font.
    '';

    homepage = "https://dejavu-fonts.github.io/";
    # Copyright (c) 2003 by Bitstream, Inc. All Rights Reserved.
    # Copyright (c) 2006 by Tavmjong Bah. All Rights Reserved.
    # DejaVu changes are in public domain
    # See http://dejavu-fonts.org/wiki/License for details
    license = lib.licenses.free;
    platforms = lib.platforms.all;
  };

  full-ttf = stdenv.mkDerivation {
    inherit version;
    inherit meta;
    pname = "dejavu-fonts-full";

    src = fetchFromGitHub {
      owner = "dejavu-fonts";
      repo = "dejavu-fonts";
      rev = "version_${lib.replaceStrings [ "." ] [ "_" ] version}";
      sha256 = "1xknlg2h287dx34v2n5r33bpcl4biqf0cv7nak657rjki7s0k4bk";
    };

    nativeBuildInputs = [
      fontforge
      perl
      perlPackages.IOString
      perlPackages.FontTTF
    ];

    buildFlags = [ "full-ttf" ];
    preBuild = "patchShebangs scripts";
    installPhase = "install -m444 -Dt $out/share/fonts/truetype build/*.ttf";
  };

  minimal = stdenv.mkDerivation {
    inherit version;
    inherit meta;
    pname = "dejavu-fonts-minimal";

    buildCommand = ''
      install -m444 -Dt $out/share/fonts/truetype ${full-ttf}/share/fonts/truetype/DejaVuSans.ttf
    '';
  };
in
stdenv.mkDerivation {
  inherit version;
  inherit meta;
  pname = "dejavu-fonts";

  buildCommand = ''
    install -m444 -Dt $out/share/fonts/truetype ${full-ttf}/share/fonts/truetype/*.ttf
    ln -s --relative --force --target-directory=$out/share/fonts/truetype ${minimal}/share/fonts/truetype/DejaVuSans.ttf
  '';

  passthru = { inherit minimal full-ttf; };
}
