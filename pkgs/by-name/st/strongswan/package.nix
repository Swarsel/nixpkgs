{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  bison,
  curl,
  flex,
  glib,
  gmp,
  gperf,
  iptables,
  ldns,
  libxml2,
  networkmanager,
  nixosTests,
  openresolv,
  openssl,
  pam,
  pcsclite,
  perl,
  pkg-config,
  sqlite,
  systemd,
  tpm2-tss,
  trousers,
  unbound,
  enableNetworkManager ? false,
  enableTNC ? false,
  enableTPM2 ? false,
}:
let
  features = rec {
    acert = true;
    aesni = stdenv.hostPlatform.isx86_64;
    af-alg = stdenv.hostPlatform.isLinux;
    chapoly = true;
    cmd = true;
    connmark = stdenv.hostPlatform.isLinux;
    # Note on curl support: If curl is built with gnutls as its backend, the
    # strongswan curl plugin may break.
    # See https://wiki.strongswan.org/projects/strongswan/wiki/Curl for more info.
    curl = true;
    dhcp = stdenv.hostPlatform.isLinux;
    dnscert = true;
    eap-aka = true;
    eap-aka-3gpp = true;
    eap-aka-3gpp2 = true;
    eap-gtc = true;
    eap-identity = true;
    eap-md5 = true;
    eap-mschapv2 = true;
    eap-peap = true;
    eap-radius = true;
    eap-sim = true;
    eap-sim-file = true;
    eap-sim-pcsc = true;
    eap-simaka-pseudonym = true;
    eap-simaka-reauth = true;
    eap-tls = true;
    ext-auth = true;
    farp = stdenv.hostPlatform.isLinux;
    forecast = stdenv.hostPlatform.isLinux;
    gmp = eap-aka-3gpp2;
    kernel-libipsec = stdenv.hostPlatform.isDarwin || stdenv.hostPlatform.isFreeBSD;
    kernel-netlink = stdenv.hostPlatform.isLinux;
    kernel-pfkey = stdenv.hostPlatform.isDarwin || stdenv.hostPlatform.isFreeBSD;
    kernel-pfroute = stdenv.hostPlatform.isDarwin || stdenv.hostPlatform.isFreeBSD;
    keychain = false; # breaks build
    ml = true;
    nm = enableNetworkManager;
    openssl = true;
    osx-attr = stdenv.hostPlatform.isDarwin;
    padlock = stdenv.hostPlatform.system == "i686-linux";
    pkcs11 = true;
    rdrand = stdenv.hostPlatform.isx86_64;
    resolve = stdenv.hostPlatform.isLinux;
    scripts = stdenv.hostPlatform.isLinux;
    socket-dynamic = stdenv.hostPlatform.isLinux;
    stroke = true;
    swanctl = true;
    systemd = stdenv.hostPlatform.isLinux;
    unbound = true;
    xauth-eap = true;
    xauth-noauth = true;
    xauth-pam = stdenv.hostPlatform.isLinux;
  }
  // lib.optionalAttrs enableTNC {
    aikgen = true;
    eap-dynamic = true;
    eap-tnc = true;
    eap-ttls = true;
    imc-attestation = true;
    imc-os = true;
    imv-attestation = true;
    imv-os = true;
    sqlite = true;
    tnc-ifmap = true;
    tnc-imc = true;
    tnc-imv = true;
    tnccs-20 = true;
    tss-trousers = true;
  }
  // lib.optionalAttrs enableTPM2 {
    tpm = true;
    tss-tss2 = true;
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "strongswan";
  version = "6.0.7"; # Make sure to also update <nixpkgs/nixos/modules/services/networking/strongswan-swanctl/swanctl-params.nix> when upgrading!

  src = fetchFromGitHub {
    owner = "strongswan";
    repo = "strongswan";
    tag = finalAttrs.version;
    hash = "sha256-OgLvCrAwFJA2t78pu+p+3DrsD53QizVotQqTiNoY1dk=";
  };

  patches = [
    ./ext_auth-path.patch
    ./firewall_defaults.patch
    ./updown-path.patch
  ];

  postPatch = lib.optionalString features.resolve ''
    substituteInPlace src/libcharon/plugins/resolve/resolve_handler.c \
      --replace-fail "/sbin/resolvconf" "${openresolv}/sbin/resolvconf"
  '';

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
    bison
    flex
    perl
    gperf
  ];

  buildInputs =
    lib.optional (features.gmp or false) gmp
    ++ lib.optional (features.eap-sim-pcsc or false) pcsclite
    ++ lib.optional (features.openssl or false) openssl
    ++ lib.optional (features.curl or false) curl
    ++ lib.optional (features.systemd or false) systemd
    ++ lib.optional (features.tnc-ifmap or false) libxml2
    ++ lib.optional (features.xauth-pam or false) pam
    ++ lib.optional (features.forecast or false || features.connmark or false) iptables
    ++ lib.optional (features.tss-trousers or false) trousers
    ++ lib.optional (features.tss-tss2 or false) tpm2-tss
    ++ lib.optional (features.sqlite or false) sqlite
    ++ lib.optionals (features.unbound or false) [
      unbound
      ldns
    ]
    ++ lib.optionals (features.nm or false) [
      networkmanager
      glib
    ];

  configureFlags = (lib.mapAttrsToList (lib.flip lib.enableFeature)) features ++ [
    "--sysconfdir=/etc"
    (lib.withFeatureAs (features.nm or false) "nm-ca-dir" "/etc/ssl/certs")
    (lib.withFeatureAs (features.systemd or false
    ) "systemdsystemunitdir" "${placeholder "out"}/etc/systemd/system")
  ];

  dontPatchELF = true;
  enableParallelBuilding = true;

  installFlags = [
    "sysconfdir=${placeholder "out"}/etc"
  ];

  passthru.tests = { inherit (nixosTests) strongswan-swanctl; };

  meta = {
    description = "OpenSource IPsec-based VPN solution";
    homepage = "https://www.strongswan.org/";
    changelog = "https://github.com/strongswan/strongswan/blob/${finalAttrs.src.rev}/NEWS";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ nickcao ];
    platforms = lib.platforms.unix;
    mainProgram = "swanctl";
  };
})
