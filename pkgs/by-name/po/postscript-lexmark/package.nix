{
  lib,
  stdenv,
  fetchurl,
  rpmextract,
}:
let
  version = "20160218";
in
stdenv.mkDerivation {
  inherit version;
  pname = "postscript-lexmark";

  src = fetchurl {
    url = "https://www.openprinting.org/download/printdriver/components/lsb3.2/main/RPMS/noarch/openprinting-ppds-postscript-lexmark-${version}-1lsb3.2.noarch.rpm";
    sha256 = "0wbhvypdr96a5ddg6kj41dn9sbl49n7pfi2vs762ij82hm2gvwcm";
  };

  nativeBuildInputs = [ rpmextract ];

  installPhase = ''
    mkdir -p $out/share/cups/model/postscript-lexmark
    cp opt/OpenPrinting-Lexmark/ppds/Lexmark/*.ppd $out/share/cups/model/postscript-lexmark/
    cp -r opt/OpenPrinting-Lexmark/doc $out/doc
  '';

  sourceRoot = ".";

  unpackPhase = ''
    rpmextract $src
    for ppd in opt/OpenPrinting-Lexmark/ppds/Lexmark/*; do
      gzip -d $ppd
    done
  '';

  meta = {
    description = "Lexmark Postscript Drivers";
    homepage = "https://www.openprinting.org/driver/Postscript-Lexmark/";
    platforms = lib.platforms.linux;
  };
}
