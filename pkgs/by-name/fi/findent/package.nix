{
  lib,
  stdenv,
  fetchurl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "findent";
  version = "4.3.7";

  src = fetchurl {
    url = "mirror://sourceforge/findent/findent-${finalAttrs.version}.tar.gz";
    hash = "sha256-4tqLjAwZYbK8nc5MbKp5ytCSRdNjiL6h/ALE7B/YuZg=";
  };

  doCheck = true;
  checkTargets = [ "installcheck" ];
  enableParallelBuilding = true;

  meta = {
    description = "Fortran source code formatter";
    homepage = "https://sourceforge.net/findent/";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ sheepforce ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "findent";
  };
})
