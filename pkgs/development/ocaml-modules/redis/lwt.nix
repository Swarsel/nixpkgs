{
  buildDunePackage,
  lwt,
  redis,
}:

buildDunePackage {
  inherit (redis) version src;
  pname = "redis-lwt";

  propagatedBuildInputs = [
    redis
    lwt
  ];

  meta = redis.meta // {
    description = "Redis client (Lwt interface)";
  };
}
