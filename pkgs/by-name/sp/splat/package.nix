{
  lib,
  stdenv,
  fetchurl,
  bzip2,
  groff,
  ncurses,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "splat";
  version = "1.4.2";

  src = fetchurl {
    url = "https://www.qsl.net/kd2bd/splat-${finalAttrs.version}.tar.bz2";
    hash = "sha256-ObCzFOLpJ73wDR7aS5hl79EouoUDBfmHrsBJxP1Yopw=";
  };

  postPatch = "patchShebangs build utils/build";

  nativeBuildInputs =
    # configure script needs `clear`
    [
      groff
      ncurses
    ];

  buildInputs = [
    bzip2
    zlib
  ];

  buildPhase = ''
    runHook preBuild
    ./build all
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -Dt $out/bin splat
    find utils -type f -executable -exec install -Dt $out/bin {} \;
    install -Dt $out/share/man/man1 docs/english/man/*.1
    install -Dt $out/share/man/es/man1 docs/spanish/man/*.1
    runHook postInstall
  '';

  configurePhase =
    # configure for maximum resolution
    ''
      runHook preConfigure
      cat > std-params.h << EOF
      #define HD_MODE 1
      #define MAXPAGES 64
      EOF
      runHook postConfigure
    '';

  meta = {
    description = "RF Signal Propagation, Loss, And Terrain analysis tool for the electromagnetic spectrum between 20 MHz and 20 GHz";
    homepage = "https://www.qsl.net/kd2bd/splat.html";
    license = lib.licenses.gpl2Only;
    platforms = lib.platforms.x86_64;
    broken = stdenv.hostPlatform.isDarwin;
  };

})
