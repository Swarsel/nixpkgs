{
  lib,
  stdenv,
  fetchurl,
  testers,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "datefmt";
  version = "0.2.2";

  src = fetchurl {
    url = "https://cdn.jb55.com/tarballs/datefmt/datefmt-${finalAttrs.version}.tar.gz";
    sha256 = "sha256-HgW/vOGVEmAbm8k3oIwIa+cogq7qmX7MfTmHqxv9lhY=";
  };

  makeFlags = [ "PREFIX=$(out)" ];
  passthru.tests.version = testers.testVersion { package = finalAttrs.finalPackage; };

  meta = {
    description = "Tool that formats timestamps in text streams";
    homepage = "https://jb55.com/datefmt";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ jb55 ];
    platforms = lib.platforms.all;
    mainProgram = "datefmt";
  };
})
