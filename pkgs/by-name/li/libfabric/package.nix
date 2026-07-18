{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  libpsm2,
  libuuid,
  numactl,
  pkg-config,
  enableOpx ? (stdenv.hostPlatform.isx86_64 && stdenv.hostPlatform.isLinux),
  enablePsm2 ? (stdenv.hostPlatform.isx86_64 && stdenv.hostPlatform.isLinux),
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libfabric";
  version = "2.6.0";

  src = fetchFromGitHub {
    owner = "ofiwg";
    repo = "libfabric";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-/zQnXfEveIGCpPZ3lgrOLnXSS7m8U2spVjkqsXuaL0o=";
  };

  outputs = [
    "out"
    "dev"
    "man"
  ];

  nativeBuildInputs = [
    pkg-config
    autoreconfHook
  ];

  buildInputs =
    lib.optionals enableOpx [
      libuuid
      numactl
    ]
    ++ lib.optionals enablePsm2 [ libpsm2 ];

  configureFlags = [
    (if enablePsm2 then "--enable-psm2=${libpsm2}" else "--disable-psm2")
    (if enableOpx then "--enable-opx" else "--disable-opx")
  ];

  enableParallelBuilding = true;

  meta = {
    description = "Open Fabric Interfaces";
    homepage = "https://ofiwg.github.io/libfabric/";

    license = with lib.licenses; [
      gpl2
      bsd2
    ];

    maintainers = [ lib.maintainers.bzizou ];
    platforms = lib.platforms.all;
  };
})
