{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  cmocka,
  ethtool,
  expect,
  fetchzip,
  hostapd,
  iw,
  libgcrypt,
  # Cygwin
  libiconv,
  libnl,
  # Linux
  libpcap,
  makeWrapper,
  openssl,
  pciutils,
  pcre2,
  pkg-config,
  screen,
  sqlite,
  tcpdump,
  usbutils,
  wirelesstools,
  wpa_supplicant,
  zlib,
  enableAirolib ? true,
  # options
  enableExperimental ? true,
  enableRegex ? true,
  useAirpcap ? stdenv.hostPlatform.isCygwin,
  useGcrypt ? false,
}:
let
  airpcap-sdk = fetchzip {
    pname = "airpcap-sdk";
    version = "4.1.1";
    extension = "zip";
    hash = "sha256-kJhnUvhnF9F/kIJx9NcbRUfIXUSX/SRaO/SWNvdkVT8=";
    stripRoot = false;
    url = "https://support.riverbed.com/bin/support/download?sid=l3vk3eu649usgu3rj60uncjqqu";
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "aircrack-ng";
  version = "1.7";

  src = fetchFromGitHub {
    owner = "aircrack-ng";
    repo = "aircrack-ng";
    tag = finalAttrs.version;
    hash = "sha256-niQDwiqi5GtBW5HIn0endnqPb/MqllcjsjXw4pTyFKY=";
  };

  postPatch = lib.optionalString stdenv.hostPlatform.isLinux ''
    substituteInPlace lib/osdep/linux.c --replace-warn /usr/local/bin ${
      lib.escapeShellArg (
        lib.makeBinPath [
          wirelesstools
        ]
      )
    }
  '';

  nativeBuildInputs = [
    pkg-config
    makeWrapper
    autoreconfHook
  ];

  buildInputs =
    lib.singleton (if useGcrypt then libgcrypt else openssl)
    ++ lib.optionals stdenv.hostPlatform.isLinux [
      libpcap
      zlib
      libnl
      iw
      ethtool
      pciutils
    ]
    ++ lib.optional (stdenv.hostPlatform.isCygwin && stdenv.cc.isClang) libiconv
    ++ lib.optional enableAirolib sqlite
    ++ lib.optional enableRegex pcre2
    ++ lib.optional useAirpcap airpcap-sdk;

  configureFlags = [
    (lib.withFeature enableExperimental "experimental")
    (lib.withFeature useGcrypt "gcrypt")
    (lib.withFeatureAs useAirpcap "airpcap" airpcap-sdk)
  ];

  nativeCheckInputs = [
    cmocka
    expect
  ];

  nativeInstallCheckInputs = [
    cmocka
    expect
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    tcpdump
    hostapd
    wpa_supplicant
    screen
  ];

  postFixup = lib.optionalString stdenv.hostPlatform.isLinux ''
    wrapProgram "$out/bin/airmon-ng" --prefix PATH : ${
      lib.escapeShellArg (
        lib.makeBinPath [
          ethtool
          iw
          pciutils
          usbutils
        ]
      )
    }
  '';

  installCheckTarget = "integration";

  meta = {
    description = "WiFi security auditing tools suite";
    homepage = "https://www.aircrack-ng.org/";
    changelog = "https://github.com/aircrack-ng/aircrack-ng/blob/${finalAttrs.src.rev}/ChangeLog";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ magistau ];

    platforms =
      with lib.platforms;
      builtins.concatLists [
        linux
        darwin
        cygwin
        netbsd
        openbsd
        freebsd
        illumos
      ];
  };
})
