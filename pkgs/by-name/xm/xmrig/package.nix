{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  hwloc,
  kmod,
  libmicrohttpd,
  libuv,
  openssl,
  donateLevel ? 0,
  enableArgon2 ? true,
  # Features (build toggles)
  enableAsm ? true,
  enableBenchmark ? true,
  enableCnFemto ? true,
  enableCnHeavy ? true,
  # Algorithms
  enableCnLite ? true,
  enableCnPico ? true,
  # Debug options
  enableDebugLog ? false,
  enableDmi ? true,
  enableGhostrider ? true,
  enableHwlocDebug ? false,
  enableKawpow ? true,
  enableMsr ? true,
  enableProfiling ? false,
  enableRandomx ? true,
  enableSse4_1 ? true,
  withHttp ? true,
  # Features requiring external dependencies
  withHwloc ? true,
  withTls ? true,
}:

stdenv.mkDerivation (finalAttrs: {
  inherit donateLevel;
  pname = "xmrig";
  version = "6.26.0";

  src = fetchFromGitHub {
    owner = "xmrig";
    repo = "xmrig";
    rev = "v${finalAttrs.version}";
    hash = "sha256-ZJKayM1kTLCXlQqqfN3MbAKPShi5OYafOdDbsMa0QIs=";
  };

  patches = [
    ./donate-level.patch
  ];

  postPatch = ''
    substituteAllInPlace src/donate.h
  ''
  + lib.optionalString withTls ''
    substituteInPlace cmake/OpenSSL.cmake \
      --replace "set(OPENSSL_USE_STATIC_LIBS TRUE)" "set(OPENSSL_USE_STATIC_LIBS FALSE)"
  ''
  + lib.optionalString (stdenv.hostPlatform.isLinux && enableMsr) ''
    substituteInPlace src/hw/msr/Msr_linux.cpp \
      --replace "/sbin/modprobe" "${kmod}/bin/modprobe"
  '';

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    libuv
  ]
  ++ lib.optional withHttp libmicrohttpd
  ++ lib.optional withTls openssl
  ++ lib.optional withHwloc hwloc;

  cmakeFlags = [
    (lib.cmakeBool "WITH_CN_LITE" enableCnLite)
    (lib.cmakeBool "WITH_CN_HEAVY" enableCnHeavy)
    (lib.cmakeBool "WITH_CN_PICO" enableCnPico)
    (lib.cmakeBool "WITH_CN_FEMTO" enableCnFemto)
    (lib.cmakeBool "WITH_RANDOMX" enableRandomx)
    (lib.cmakeBool "WITH_ARGON2" enableArgon2)
    (lib.cmakeBool "WITH_KAWPOW" enableKawpow)
    (lib.cmakeBool "WITH_GHOSTRIDER" enableGhostrider)

    (lib.cmakeBool "WITH_HWLOC" withHwloc)
    (lib.cmakeBool "WITH_HTTP" withHttp)
    (lib.cmakeBool "WITH_TLS" withTls)

    (lib.cmakeBool "WITH_ASM" enableAsm)
    (lib.cmakeBool "WITH_MSR" enableMsr)
    (lib.cmakeBool "WITH_PROFILING" enableProfiling)
    (lib.cmakeBool "WITH_SSE4_1" enableSse4_1)
    (lib.cmakeBool "WITH_BENCHMARK" enableBenchmark)
    (lib.cmakeBool "WITH_DMI" enableDmi)

    (lib.cmakeBool "WITH_DEBUG_LOG" enableDebugLog)
    (lib.cmakeBool "HWLOC_DEBUG" enableHwlocDebug)
  ];

  installPhase = ''
    runHook preInstall

    install -vD ${if withTls then "xmrig" else "xmrig-notls"} $out/bin/xmrig

    runHook postInstall
  '';

  # https://github.com/NixOS/nixpkgs/issues/245534
  hardeningDisable = [ "fortify" ];

  meta = {
    description = "Monero (XMR) CPU miner";
    homepage = "https://github.com/xmrig/xmrig";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ kim0 ];
    platforms = lib.platforms.unix;
    mainProgram = "xmrig";
  };
})
