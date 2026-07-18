{
  lib,
  stdenv,
  fetchFromGitHub,
  copyDesktopItems,
  groff,
  installShellFiles,
  libxext,
  libxmu,
  libxt,
  makeDesktopItem,
  motif,
  openssl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "xephem";
  version = "4.3.0";

  src = fetchFromGitHub {
    owner = "XEphem";
    repo = "XEphem";
    tag = finalAttrs.version;
    hash = "sha256-zWINscuRO7k/q3u1hngcIkfOpxX75HUxxB2X41igdBg=";
  };

  patches = [
    ./add-cross-compilation-support.patch
  ];

  postPatch = ''
    cd GUI/xephem
    substituteInPlace xephem.c splash.c --replace-fail '/etc/XEphem' '${placeholder "out"}/etc/XEphem'
  '';

  nativeBuildInputs = [
    copyDesktopItems
    installShellFiles
    groff # nroff
  ];

  buildInputs = [
    motif
    openssl
    libxmu
    libxext
    libxt
  ];

  makeFlags = [
    "CC=${stdenv.cc.targetPrefix}cc"
    "AR=${stdenv.cc.targetPrefix}ar"
    "RANLIB=${stdenv.cc.targetPrefix}ranlib"
  ];

  env.NIX_CFLAGS_COMPILE = "-std=gnu17";
  doCheck = true;
  checkFlags = "-C ../../tests";

  installPhase = ''
    runHook preInstall
    installBin xephem
    mkdir -p $out/share/xephem
    cp -R auxil $out/share/xephem/
    cp -R catalogs $out/share/xephem/
    cp -R fifos $out/share/xephem/
    cp -R fits $out/share/xephem/
    cp -R gallery $out/share/xephem/
    cp -R help $out/share/xephem/
    cp -R lo $out/share/xephem/
    mkdir $out/etc
    echo "XEphem.ShareDir: $out/share/xephem" > $out/etc/XEphem
    installManPage xephem.1
    install -Dm644 XEphem.png -t $out/share/icons/hicolor/128x128/apps
    runHook postInstall
  '';

  checkTarget = "run-test";

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "Science"
        "Astronomy"
      ];

      desktopName = "XEphem";
      exec = "xephem";
      icon = "XEphem";
      name = "xephem";
    })
  ];

  enableParallelBuilding = true;

  meta = {
    description = "Interactive astronomy program for all UNIX platforms";

    longDescription = ''
      Xephem is an interactive astronomical ephemeris program for X Windows systems. It computes
      heliocentric, geocentric and topocentric information for fixed celestial objects and objects
      in heliocentric and geocentric orbits; has built-in support for all planet positions; the
      moons of Jupiter, Saturn and Earth; Mars' and Jupiter's central meridian longitude; Saturn's
      rings; and Jupiter's Great Red Spot.
    '';

    homepage = "https://xephem.github.io/XEphem/Site/xephem.html";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "xephem";
  };
})
