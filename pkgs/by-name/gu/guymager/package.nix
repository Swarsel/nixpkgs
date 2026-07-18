{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  libbfio,
  libewf-legacy,
  libguytools,
  libsForQt5,
  parted,
  udev,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "guymager";
  version = "0.8.13";

  src = fetchurl {
    url = "mirror://sourceforge/project/guymager/guymager/LatestSource/guymager-${finalAttrs.version}.tar.gz";
    hash = "sha256-xDsQ/d6fyfLOr4uXpdoqMljfFrVgQTUu0t2e5opcaRg=";
  };

  postPatch = ''
    patchShebangs compileinfo.sh
    substituteInPlace manuals/guymager_body.1 config.cpp \
      --replace-fail "/etc/guymager/guymager.cfg" "$out/share/guymager/guymager.cfg"
    substituteInPlace compileinfo.sh \
      --replace-fail " debian/changelog" "" \
      --replace-fail "dpkg-parsechangelog" "dpkg-parsechangelog -l changelog"
    substituteInPlace threadscan.cpp \
    --replace-fail '/lib,/usr/lib,/usr/lib64,/usr/local/lib' '${
      builtins.replaceStrings [ ":" ] [ "," ] (
        lib.makeLibraryPath [
          udev
          parted
        ]
      )
    }'
    substituteInPlace org.freedesktop.guymager.policy guymager.pro main.cpp guymager.cfg \
      --replace-fail /usr $out
  '';

  nativeBuildInputs = [
    dpkg
    libsForQt5.qmake
    libsForQt5.qttools
    libsForQt5.wrapQtAppsHook
  ];

  buildInputs = [
    libsForQt5.qtbase
    libewf-legacy
    libbfio
    libguytools
    parted
    udev
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/{bin,share}
    make clean
    rm -rf *.cpp *.h *.pro
    cp -aR . "$out/share/guymager/"
    makeWrapper $out/share/guymager/guymager $out/bin/guymager
    runHook postInstall
  '';

  enableParallelBuilding = true;

  meta = {
    description = "Forensic imager for media acquisition";
    homepage = "https://guymager.sourceforge.io";
    license = lib.licenses.gpl2Only;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "guymager";
  };
})
