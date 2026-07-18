{
  lib,
  stdenv,
  fetchurl,
  coreutils,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "entr";
  version = "5.8";

  src = fetchurl {
    url = "https://eradman.com/entrproject/code/entr-${finalAttrs.version}.tar.gz";
    hash = "sha256-3Jor3FVrK+kAwdjN9DLeJkkt5a8/+t4ADUv9l/MSK/s=";
  };

  postPatch = ''
    substituteInPlace entr.c --replace /bin/cat ${coreutils}/bin/cat
    substituteInPlace entr.1 --replace /bin/cat cat
  '';

  env.TARGET_OS = stdenv.hostPlatform.uname.system;
  doCheck = true;
  checkTarget = "test";
  dontAddPrefix = true;
  installFlags = [ "PREFIX=$(out)" ];

  meta = {
    description = "Run arbitrary commands when files change";
    homepage = "https://eradman.com/entrproject/";
    changelog = "https://github.com/eradman/entr/raw/${finalAttrs.version}/NEWS";
    license = lib.licenses.isc;

    maintainers = with lib.maintainers; [
      pSub
    ];

    platforms = lib.platforms.all;
    mainProgram = "entr";
  };
})
