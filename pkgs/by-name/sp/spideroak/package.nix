{
  lib,
  stdenv,
  fetchurl,
  fontconfig,
  freetype,
  glib,
  libice,
  libsm,
  libx11,
  libxext,
  libxrender,
  makeWrapper,
  patchelf,
  zlib,
}:

let
  hash = "sha256-L9AF5gOmvbN+Ur1k0oIjJJT15RZvWA7mhDgveVowu7E=";

  ldpath = lib.makeLibraryPath [
    fontconfig
    freetype
    glib
    libice
    libsm
    libx11
    libxext
    libxrender
    zlib
  ];

  version = "7.5.2";

in
stdenv.mkDerivation {
  inherit version;
  pname = "spideroak";

  src = fetchurl {
    inherit hash;
    url = "https://spideroak-releases.s3.us-east-2.amazonaws.com/SpiderOakONE-${version}-x86_64-1.tgz";
    name = "SpiderOakONE-${version}-x86_64-1.tgz";
  };

  nativeBuildInputs = [
    patchelf
    makeWrapper
  ];

  installPhase = ''
    runHook preInstall

    mkdir "$out"
    cp -r "./"* "$out"
    mkdir "$out/bin"
    rm "$out/usr/bin/SpiderOakONE"
    rmdir $out/usr/bin || true
    mv $out/usr/share $out/

    rm -f $out/opt/SpiderOakONE/lib/libz*

    patchelf --set-interpreter ${stdenv.cc.libc}/lib/ld-linux-x86-64.so.2 \
      "$out/opt/SpiderOakONE/lib/SpiderOakONE"

    RPATH=$out/opt/SpiderOakONE/lib:${ldpath}
    makeWrapper $out/opt/SpiderOakONE/lib/SpiderOakONE $out/bin/spideroak --set LD_LIBRARY_PATH $RPATH \
      --set QT_PLUGIN_PATH $out/opt/SpiderOakONE/lib/plugins/ \
      --set SpiderOak_EXEC_SCRIPT $out/bin/spideroak

    sed -i 's/^Exec=.*/Exec=spideroak/' $out/share/applications/SpiderOakONE.desktop

    runHook postInstall
  '';

  sourceRoot = ".";
  unpackCmd = "tar -xzf $curSrc";

  meta = {
    description = "Secure online backup and sychronization";
    homepage = "https://spideroak.com";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "spideroak";
  };
}
