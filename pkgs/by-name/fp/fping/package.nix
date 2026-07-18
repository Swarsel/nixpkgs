{
  lib,
  stdenv,
  fetchurl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "fping";
  version = "5.5";

  src = fetchurl {
    url = "https://www.fping.org/dist/fping-${finalAttrs.version}.tar.gz";
    hash = "sha256-FcTjK2xV/xBbr+A+jJHHyhsu2jG/mnEnMmu4eIfuGP4=";
  };

  outputs = [
    "out"
    "man"
  ];

  configureFlags = [
    "--enable-ipv6"
    "--enable-ipv4"
  ];

  meta = {
    description = "Send ICMP echo probes to network hosts";
    homepage = "http://fping.org/";
    changelog = "https://github.com/schweikert/fping/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.bsd0;
    maintainers = with lib.maintainers; [ fab ];
    platforms = lib.platforms.all;
    mainProgram = "fping";
  };
})
