{
  lib,
  stdenv,
  fetchurl,
  alsa-lib,
  amoeba-data,
  expat,
  freetype,
  gtk3,
  installShellFiles,
  libGLU,
  libvorbis,
  libxxf86vm,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "amoeba";
  version = "1.1";

  postPatch = ''
    sed -i packer/pakfile.cpp -e 's|/usr/share/amoeba|${amoeba-data}/share/amoeba|'
    sed -i main/linux-config/linux-config.cpp -e 's|libgdk-x11-2.0.so.0|${gtk3}/lib/&|'
    sed -i main/linux-config/linux-config.cpp -e 's|libgtk-x11-2.0.so.0|${gtk3}/lib/&|'
  '';

  nativeBuildInputs = [
    pkg-config
    installShellFiles
  ];

  buildInputs = [
    alsa-lib
    expat
    freetype
    gtk3
    libvorbis
    libGLU
    libxxf86vm
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp amoeba $out/bin/
    installManPage ../debian/amoeba.1
  '';

  debver = "31";

  prePatch = ''
    patches="${./include-string-h.patch} $(echo ../debian/patches/*.diff)"
  '';

  sourceRoot = "amoeba-1.1.orig";

  srcs = [
    (fetchurl {
      hash = "sha256-NT6oMuAlTcVZEnYjMCF+BD+k3/w7LfWEmj6bkQln3sM=";
      url = "http://http.debian.net/debian/pool/contrib/a/amoeba/amoeba_${finalAttrs.version}.orig.tar.gz";
    })
    (fetchurl {
      hash = "sha256-Ga/YeXbPXjkG/6qd9Z201d14Hlj/Je6DxgzeIQOqrWc=";
      url = "http://http.debian.net/debian/pool/contrib/a/amoeba/amoeba_${finalAttrs.version}-${finalAttrs.debver}.debian.tar.xz";
    })
  ];

  meta = {
    description = "Fast-paced, polished OpenGL demonstration by Excess";
    homepage = "https://packages.qa.debian.org/a/amoeba.html";
    license = lib.licenses.gpl2Only; # Engine is GPLv2, data files in amoeba-data nonfree
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };
})
