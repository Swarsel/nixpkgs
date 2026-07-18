{
  lib,
  stdenv,
  fetchurl,
  autoreconfHook,
  gitUpdater,
  gnum4,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "adns";
  version = "1.6.1";

  src = fetchurl {
    hash = "sha256-cTizeJt1Br1oP0UdT32FMHepGAO3s12G7GZ/D5zUAc0=";

    urls = [
      "https://www.chiark.greenend.org.uk/~ian/adns/ftp/adns-${finalAttrs.version}.tar.gz"
      "mirror://gnu/adns/adns-${finalAttrs.version}.tar.gz"
    ];
  };

  patches = lib.optionals stdenv.hostPlatform.isDarwin [ ./darwin.patch ];

  nativeBuildInputs = [
    gnum4
    autoreconfHook
  ];

  configureFlags = lib.optional stdenv.hostPlatform.isStatic "--disable-dynamic";
  # https://www.mail-archive.com/nix-dev@cs.uu.nl/msg01347.html for details.
  doCheck = false;
  doInstallCheck = true;

  installCheckPhase = ''
    runHook preInstallCheck

    for prog in $out/bin/*; do
      $prog --help > /dev/null && echo $(basename $prog) shows usage
    done

    runHook postInstallCheck
  '';

  enableParallelBuilding = true;

  passthru.updateScript = gitUpdater {
    rev-prefix = "adns-";
    url = "https://www.chiark.greenend.org.uk/ucgi/~ianmdlvl/githttp/adns.git";
  };

  meta = {
    description = "Asynchronous DNS resolver library";
    homepage = "http://www.chiark.greenend.org.uk/~ian/adns/";

    license = [
      lib.licenses.gpl3Plus

      # `adns.h` only
      lib.licenses.lgpl2Plus
    ];

    platforms = lib.platforms.unix;
  };
})
