{
  lib,
  stdenv,
  fetchurl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "papi";
  version = "7.2.0";

  src = fetchurl {
    url = "https://icl.utk.edu/projects/papi/downloads/papi-${finalAttrs.version}.tar.gz";
    sha256 = "sha256-qb/4nM85kV1yngiuCgxqcc4Ou+mEEemi6zyDyNsK85w=";
  };

  doCheck = true;
  checkTarget = "test";

  setSourceRoot = ''
    sourceRoot=$(echo */src)
  '';

  meta = {
    description = "Library providing access to various hardware performance counters";
    homepage = "https://icl.utk.edu/papi/";
    license = lib.licenses.bsdOriginal;

    maintainers = with lib.maintainers; [
      costrouc
      zhaofengli
    ];

    platforms = lib.platforms.linux;
  };
})
