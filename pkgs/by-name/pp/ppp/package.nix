{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  bash,
  fetchpatch,
  libpcap,
  libxcrypt,
  linux-pam,
  nixosTests,
  openssl,
  pkg-config,
  systemdMinimal,
  withSystemd ? lib.meta.availableOn stdenv.hostPlatform systemdMinimal,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ppp";
  version = "2.5.2";

  src = fetchFromGitHub {
    owner = "ppp-project";
    repo = "ppp";
    tag = "v${finalAttrs.version}";
    hash = "sha256-NV8U0F8IhHXn0YuVbfFr992ATQZaXA16bb5hBIwm9Gs=";
  };

  patches = [
    # Fix build with gcc15
    # https://github.com/ppp-project/ppp/pull/548
    (fetchpatch {
      hash = "sha256-ybuWyA1t9IJ1Sg06a0b0tin4qssr0qzmenfGoA1X0BE=";
      url = "https://github.com/ppp-project/ppp/commit/05361692ee7d6260ce5c04c9fa0e5a1aa7565323.patch";
    })
  ];

  postPatch = ''
    for file in $(find -name Makefile.linux); do
      substituteInPlace "$file" --replace '-m 4550' '-m 550'
    done

    patchShebangs --host \
      scripts/{pon,poff,plog}
  '';

  nativeBuildInputs = [
    pkg-config
    autoreconfHook
  ];

  buildInputs = [
    bash
    libpcap
    libxcrypt
    linux-pam
    openssl
  ]
  ++ lib.optionals withSystemd [
    systemdMinimal
  ];

  configureFlags = [
    "--localstatedir=/var"
    "--sysconfdir=/etc"
    "--with-openssl=${openssl.dev}"
    (lib.enableFeature withSystemd "systemd")
  ];

  makeFlags = [
    "CC=${stdenv.cc.targetPrefix}cc"
  ];

  env.NIX_LDFLAGS = "-lcrypt";

  postInstall = ''
    install -Dm755 -t $out/bin scripts/{pon,poff,plog}
  '';

  postFixup = ''
    substituteInPlace "$out/bin/pon" --replace "/usr/sbin" "$out/bin"
  '';

  enableParallelBuilding = true;

  installFlags = [
    "sysconfdir=$(out)/etc"
  ];

  passthru.tests = {
    inherit (nixosTests) pppd;
  };

  meta = {
    description = "Point-to-point implementation to provide Internet connections over serial lines";
    homepage = "https://ppp.samba.org";

    license = with lib.licenses; [
      bsdOriginal
      publicDomain
      gpl2Only
      lgpl2
    ];

    maintainers = with lib.maintainers; [ stv0g ];
    platforms = lib.platforms.linux;
  };
})
