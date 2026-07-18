{
  lib,
  stdenv,
  fetchurl,
  dpkg,
}:

let
  version = "20030809";
in
stdenv.mkDerivation {
  inherit version;
  pname = "kochi-substitute";

  src = fetchurl {
    url = "mirror://debian/pool/main/t/ttf-kochi/ttf-kochi-gothic_${version}-15_all.deb";
    sha256 = "6e2311cd8e880a9328e4d3eef34a1c1f024fc87fba0dce177a0e1584a7360fea";
  };

  nativeBuildInputs = [ dpkg ];

  installPhase = ''
    mkdir -p $out/share/fonts/truetype
    cp ./share/fonts/truetype/kochi/kochi-gothic-subst.ttf $out/share/fonts/truetype/
    cp ./share/fonts/truetype/kochi/kochi-mincho-subst.ttf $out/share/fonts/truetype/
  '';

  outputHash = "10hcrf51npc1w2jsz5aiw07dgw96vs4wmsz4ai9zyaswipvf8ddy";
  outputHashAlgo = "sha256";
  outputHashMode = "recursive";

  src2 = fetchurl {
    sha256 = "91ce6c993a3a0f77ed85db76f62ce18632b4c0cbd8f864676359a17ae5e6fa3c";
    url = "mirror://debian/pool/main/t/ttf-kochi/ttf-kochi-mincho_${version}-15_all.deb";
  };

  unpackCmd = ''
    dpkg-deb --fsys-tarfile $src | tar xf - ./usr/share/fonts/truetype/kochi/kochi-gothic-subst.ttf
    dpkg-deb --fsys-tarfile $src2 | tar xf - ./usr/share/fonts/truetype/kochi/kochi-mincho-subst.ttf
  '';

  meta = {
    description = "Japanese font, a free replacement for MS Gothic and MS Mincho";

    longDescription = ''
      Kochi Gothic and Kochi Mincho were developed as free replacements for the
      MS Gothic and MS Mincho fonts from Microsoft. These are the Debian
      versions of the fonts, which remove some non-free glyphs that were added
      from the naga10 font.
    '';

    homepage = "https://osdn.net/projects/efont/";
    license = lib.licenses.wadalab;
    maintainers = [ lib.maintainers.auntie ];
  };
}
