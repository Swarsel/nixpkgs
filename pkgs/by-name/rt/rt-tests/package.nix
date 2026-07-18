{
  lib,
  stdenv,
  fetchurl,
  makeWrapper,
  numactl,
  python3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "rt-tests";
  version = "2.10";

  src = fetchurl {
    url = "https://git.kernel.org/pub/scm/utils/rt-tests/rt-tests.git/snapshot/rt-tests-${finalAttrs.version}.tar.gz";
    sha256 = "sha256-LHlihC7otuP/yXXiZ0XdQ4gSpyGKX6qVvGoouWq7CyM=";
  };

  nativeBuildInputs = [ makeWrapper ];

  buildInputs = [
    numactl
    python3
  ];

  makeFlags = [
    "prefix=$(out)"
    "DESTDIR="
    "PYLIB=$(out)/${python3.sitePackages}"
    "CC=${stdenv.cc.targetPrefix}cc"
    "AR=${stdenv.cc.bintools.targetPrefix}ar"
  ];

  env.NIX_CFLAGS_COMPILE = "-Wno-error=format-overflow";

  postInstall = ''
    wrapProgram "$out/bin/determine_maximum_mpps.sh" --prefix PATH : $out/bin
  '';

  meta = {
    description = "Suite of real-time tests - cyclictest, hwlatdetect, pip_stress, pi_stress, pmqtest, ptsematest, rt-migrate-test, sendme, signaltest, sigwaittest, svsematest";
    homepage = "https://git.kernel.org/pub/scm/utils/rt-tests/rt-tests.git";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ poelzi ];
    platforms = lib.platforms.linux;
  };
})
