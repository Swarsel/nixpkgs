{
  lib,
  stdenv,
  fetchFromGitHub,
  cairo,
  freetype,
  gfortran,
  giza,
  hdf5,
  versionCheckHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "splash";
  version = "3.12.0";

  src = fetchFromGitHub {
    owner = "danieljprice";
    repo = "splash";
    rev = "v${finalAttrs.version}";
    hash = "sha256-7wzFYaceryxbNRLRv7EikWr4yYjrK89S7Kct8kpKvz8=";
  };

  nativeBuildInputs = [
    gfortran
  ];

  buildInputs = [
    giza
    cairo
    freetype
    hdf5
  ];

  makeFlags = [
    "SYSTEM=gfortran"
    "GIZA_DIR=${giza}"
    "PREFIX=${placeholder "out"}"
  ];

  # Upstream's simplistic makefile doesn't even `mkdir $(PREFIX)`, so we help
  # it:
  preInstall = ''
    mkdir -p $out/bin
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  meta = {
    inherit (finalAttrs.src.meta) homepage;
    description = "Interactive visualisation and plotting tool using kernel interpolation, mainly used for Smoothed Particle Hydrodynamics simulations";
    license = lib.licenses.lgpl3Plus;
    maintainers = with lib.maintainers; [ doronbehar ];
    platforms = lib.platforms.all;
  };
})
