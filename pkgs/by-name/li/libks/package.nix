{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ctestCheckHook,
  fetchpatch,
  freeswitch,
  libossp_uuid,
  libuuid,
  nix-update-script,
  openssl,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libks";
  version = "2.0.11";

  src = fetchFromGitHub {
    owner = "signalwire";
    repo = "libks";
    tag = "v${finalAttrs.version}";
    hash = "sha256-tPhGXDEAKgeODAcM6hu4GDU83A3Zi7sIMnTQkfCGlFc=";
  };

  patches = [
    (fetchpatch {
      sha256 = "1hyrsdxg69d08qzvf3mbrx2363lw52jcybw8i3ynzqcl228gcg8a";
      url = "https://raw.githubusercontent.com/openwrt/telephony/5ced7ea4fc9bd746273d564bf3c102f253d2182e/libs/libks/patches/01-find-libm.patch";
    })
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    openssl
  ]
  ++ lib.optional stdenv.hostPlatform.isLinux libuuid
  ++ lib.optional stdenv.hostPlatform.isDarwin libossp_uuid;

  doCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;

  nativeCheckInputs = [
    ctestCheckHook
  ];

  # Some tests require this on Darwin
  __darwinAllowLocalNetworking = true;

  disabledTests = [
    # Runs into certificate error on aarch64
    # [ERROR] [...] testhttp.c:95    init_ssl [...] SSL ERR: CERT CHAIN FILE ERROR
    "testhttp"

    # Runs into what seems like an overflow / memory corruption in the testing framework on the community runner.
    # Doesn't happen on local ARM hardware, maybe due to unexpectedly high core count?
    "testthreadmutex"
  ];

  dontUseCmakeBuildDir = true;
  # Something seems to go wrong with testwebsock2 when using parallelism
  enableParallelChecking = false;

  passthru = {
    tests.freeswitch = freeswitch;
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Foundational support for signalwire C products";
    homepage = "https://github.com/signalwire/libks";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ misuzu ];
    platforms = lib.platforms.unix;
    teams = [ lib.teams.ngi ];
  };
})
