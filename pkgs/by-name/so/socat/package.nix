{
  lib,
  stdenv,
  fetchurl,
  buildPackages,
  net-tools,
  openssl,
  readline,
  which,
}:

stdenv.mkDerivation rec {
  pname = "socat";
  version = "1.8.1.3";

  src = fetchurl {
    url = "http://www.dest-unreach.org/socat/download/socat-${version}.tar.bz2";
    hash = "sha256-JbxkdikrLmFCIJicd7C2/Kh7slJdl0ezGmY5sftgJBg=";
  };

  postPatch = ''
    patchShebangs test.sh
    substituteInPlace test.sh \
      --replace /bin/rm rm \
      --replace /sbin/ifconfig ifconfig
  '';

  buildInputs = [
    openssl
    readline
  ];

  configureFlags =
    lib.optionals (!stdenv.hostPlatform.isLinux) [
      "--disable-posixmq"
    ]
    ++ lib.optionals stdenv.hostPlatform.isFreeBSD [
      "--disable-dccp"
    ];

  doCheck = false; # fails a bunch, hangs

  nativeCheckInputs = [
    which
    net-tools
  ];

  enableParallelBuilding = true;

  passthru.tests = lib.optionalAttrs stdenv.buildPlatform.isLinux {
    musl = buildPackages.pkgsMusl.socat;
  };

  meta = {
    description = "Utility for bidirectional data transfer between two independent data channels";
    homepage = "http://www.dest-unreach.org/socat/";
    license = with lib.licenses; [ gpl2Only ];
    maintainers = with lib.maintainers; [ ryan4yin ];
    platforms = lib.platforms.unix;
    mainProgram = "socat";
  };
}
