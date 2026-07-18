{
  lib,
  stdenv,
  fetchurl,
  hdf5,
  matio,
  nix-update-script,
  pkgconf,
  testers,
  validatePkgConfig,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "matio";
  version = "1.5.30";

  src = fetchurl {
    url = "mirror://sourceforge/matio/matio-${finalAttrs.version}.tar.gz";
    hash = "sha256-i9O5R3BC7MAN1xwEdi+lhGjhTMzDL9jGgmwtoei8MQc=";
  };

  nativeBuildInputs = [
    pkgconf
    validatePkgConfig
  ];

  buildInputs = [
    hdf5
    zlib
  ];

  configureFlags = [ "ac_cv_va_copy=1" ];

  passthru = {
    tests = {
      version = testers.testVersion {
        package = matio;
      };

      pkg-config = testers.hasPkgConfigModules {
        package = matio;
        versionCheck = true;
      };
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "C library for reading and writing Matlab MAT files";
    homepage = "https://matio.sourceforge.net/";
    changelog = "https://sourceforge.net/p/matio/news/";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ jwillikers ];
    platforms = lib.platforms.all;
    mainProgram = "matdump";
    pkgConfigModules = [ "matio" ];
  };
})
