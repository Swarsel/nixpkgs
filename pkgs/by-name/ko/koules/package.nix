{
  lib,
  stdenv,
  fetchurl,
  copyDesktopItems,
  fetchzip,
  gccmakedep,
  imagemagick,
  imake,
  installShellFiles,
  libx11,
  libxext,
  makeDesktopItem,
}:

let
  debian-extras = fetchzip {
    hash = "sha256-8AQGU3uAu1nCKeu4nqCDOL7FcSJeYvD1pmidEPLLekY=";
    url = "mirror://debian/pool/main/k/koules/koules_1.4-29.debian.tar.xz";
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "koules";
  version = "1.4";

  src = fetchurl {
    url = "https://www.ucw.cz/~hubicka/koules/packages/koules${finalAttrs.version}-src.tar.gz";
    hash = "sha256-w2+T/q/uvVmYO/RBACQOZ6hKi6yr1+5SjJMEbe/kohs=";
  };

  postPatch = ''
    # We do not want to depend on that particular font to be available in the
    # xserver, hence substitute it by a font which is always available
    sed -i -e 's:-schumacher-clean-bold-r-normal--8-80-75-75-c-80-\*iso\*:fixed:' xlib/init.c
  '';

  nativeBuildInputs = [
    imake
    gccmakedep
    installShellFiles
    copyDesktopItems
    imagemagick
  ];

  buildInputs = [
    libx11
    libxext
  ];

  preBuild = ''
    cp xkoules.6 xkoules.man  # else "make" will not succeed
    sed -i -e "s:^SOUNDDIR\s*=.*:SOUNDDIR=$out/lib:" Makefile
    sed -i -e "s:^KOULESDIR\s*=.*:KOULESDIR=$out:" Makefile
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 xkoules $out/bin/xkoules
    install -Dm755 koules.sndsrv.linux $out/lib/koules.sndsrv.linux
    install -m644 sounds/* $out/lib/
    mkdir -p $out/share/icons/hicolor/32x32/apps
    magick Koules.xpm -background none -extent 32x32-1 -gravity center $out/share/icons/hicolor/32x32/apps/koules.png
    installManPage xkoules.6
    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "Game"
        "ArcadeGame"
      ];

      comment = "Push your enemies away, but stay away from obstacles";
      desktopName = "Koules";
      exec = "xkoules";
      icon = "koules";
      name = "koules";
    })
  ];

  # Debian maintains lots of patches for koules. Let's include all of them.
  prePatch = ''
    patches="$patches $(cat ${debian-extras}/patches/series | sed 's|^|${debian-extras}/patches/|')"
  '';

  meta = {
    description = "Fast arcade game based on the fundamental law of body attraction";
    homepage = "https://www.ucw.cz/~hubicka/koules/English/";
    license = lib.licenses.gpl2Plus;
    maintainers = [ lib.maintainers.iblech ];
    platforms = lib.platforms.linux;
    mainProgram = "xkoules";
  };
})
