{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  libevent,
  openssl,
  pkg-config,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "memtier-benchmark";
  version = "2.4.4";

  src = fetchFromGitHub {
    owner = "redis";
    repo = "memtier_benchmark";
    tag = finalAttrs.version;
    hash = "sha256-2r/8u+gbgN6zwOoVfA9QCAXeYOK15znq03b6OcS+FLM=";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    libevent
    zlib
    openssl
  ];

  meta = {
    description = "Redis and Memcached traffic generation and benchmarking tool";
    homepage = "https://github.com/redis/memtier_benchmark";
    changelog = "https://github.com/redis/memtier_benchmark/releases/tag/${finalAttrs.version}";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ thoughtpolice ];
    platforms = lib.platforms.unix;
    mainProgram = "memtier_benchmark";
    teams = [ lib.teams.redis ];
  };
})
