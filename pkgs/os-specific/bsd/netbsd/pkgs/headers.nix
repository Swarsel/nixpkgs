{
  lib,
  include,
  libpthread-headers,
  symlinkJoin,
  sys-headers,
}:

symlinkJoin {
  name = "netbsd-headers-9.2";

  paths = [
    include
    sys-headers
    libpthread-headers
  ];

  meta.platforms = lib.platforms.netbsd;
}
