{
  lib,
  stdenv,
  fetchurl,
  fetchpatch,
  lksctp-tools,
  openssl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "iperf";
  version = "3.21";

  src = fetchurl {
    url = "https://downloads.es.net/pub/iperf/iperf-${finalAttrs.version}.tar.gz";
    hash = "sha256-ZW5EBevWIBId587KPq9DqI956huFfQQaagsTFIAazdg=";
  };

  outputs = [
    "out"
    "dev"
    "lib"
    "man"
  ];

  patches = lib.optionals stdenv.hostPlatform.isMusl [
    (fetchpatch {
      hash = "sha256-cT3etRWaNRQrw7Gz4oTp6L5SJdKI/lrDywhYelzVf3w=";
      name = "remove-pg-flags.patch";
      url = "https://git.alpinelinux.org/aports/plain/main/iperf3/remove-pg-flags.patch?id=7f979fc51ae31d5c695d8481ba84a4afc5080efb";
    })
  ];

  strictDeps = true;
  buildInputs = [ openssl ] ++ lib.optionals stdenv.hostPlatform.isLinux [ lksctp-tools ];
  configureFlags = [ "--with-openssl=${openssl.dev}" ];

  postInstall = ''
    ln -s $out/bin/iperf3 $out/bin/iperf
    ln -s $man/share/man/man1/iperf3.1 $man/share/man/man1/iperf.1
  '';

  __structuredAttrs = true;

  meta = {
    description = "Tool to measure IP bandwidth using UDP or TCP";
    homepage = "https://software.es.net/iperf/";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ fpletz ];
    platforms = lib.platforms.unix;
    mainProgram = "iperf3";
  };
})
