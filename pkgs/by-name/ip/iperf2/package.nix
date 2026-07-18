{
  lib,
  stdenv,
  fetchurl,
  pkgsCross,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "iperf";
  version = "2.2.1";

  src = fetchurl {
    url = "mirror://sourceforge/iperf2/files/iperf-${finalAttrs.version}.tar.gz";
    hash = "sha256-dUqwp+KAM9vqgTCO9CS8ffTW4v4xtgzFNrYbUf772Ps=";
  };

  strictDeps = true;
  configureFlags = [ "--enable-fastsampling" ];
  makeFlags = [ "AR:=$(AR)" ];

  postInstall = ''
    mv $out/bin/iperf $out/bin/iperf2
    ln -s $out/bin/iperf2 $out/bin/iperf
  '';

  __structuredAttrs = true;

  passthru.tests = {
    cross-aarch64 = pkgsCross.aarch64-multiplatform.iperf2;
  };

  meta = {
    description = "Tool to measure IP bandwidth using UDP or TCP";
    homepage = "https://sourceforge.net/projects/iperf/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ randomizedcoder ];
    platforms = lib.platforms.unix;
    mainProgram = "iperf2";
    # prioritize iperf3
    priority = 10;
  };
})
