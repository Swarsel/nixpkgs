{
  lib,
  stdenv,
  fetchurl,
  fontforge,
  google-fonts,
  migu,
  which,
}:

stdenv.mkDerivation rec {
  pname = "ricty";
  version = "4.1.1";

  src = fetchurl {
    url = "https://rictyfonts.github.io/files/ricty_generator-${version}.sh";
    sha256 = "03fngb8f5hl7ifigdm5yljhs4z2x80cq8y8kna86d07ghknhzgw6";
  };

  buildInputs = [
    google-fonts
    migu
    fontforge
    which
  ];

  buildPhase = ''
    inconsolata=${google-fonts} migu=${migu} ./ricty_generator.sh auto
  '';

  installPhase = ''
    install -m644 --target $out/share/fonts/truetype/ricty -D Ricty-*.ttf
  '';

  patchPhase = ''
    sed -i 's/fonts_directories=".*"/fonts_directories="$inconsolata $migu"/' ricty_generator.sh
  '';

  unpackPhase = ''
    install -m 0770 $src ricty_generator.sh
  '';

  meta = {
    description = "High-quality Japanese font based on Inconsolata and Migu 1M";
    homepage = "https://rictyfonts.github.io";
    license = lib.licenses.unfree;
    maintainers = [ lib.maintainers.mikoim ];
  };
}
