{
  lib,
  stdenv,
  fetchurl,
  autoreconfHook,
  net-snmp,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ifstat-legacy";
  version = "1.1";

  src = fetchurl {
    url = "http://gael.roualland.free.fr/ifstat/ifstat-${finalAttrs.version}.tar.gz";
    sha256 = "01zmv6vk5kh5xmd563xws8a1qnxjb6b6kv59yzz9r3rrghxhd6c5";
  };

  nativeBuildInputs = [ autoreconfHook ];
  buildInputs = lib.optional stdenv.hostPlatform.isLinux net-snmp;

  postInstall = ''
    mv $out/bin/ifstat $out/bin/ifstat-legacy
    mv $out/share/man/man1/ifstat.1 $out/share/man/man1/ifstat-legacy.1
  '';

  enableParallelBuilding = true;

  meta = {
    description = "Report network interfaces bandwith just like vmstat/iostat do for other system counters - legacy version";
    homepage = "http://gael.roualland.free.fr/ifstat/";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ peterhoeg ];
    platforms = lib.platforms.unix;
    mainProgram = "ifstat-legacy";
  };
})
