{
  lib,
  stdenv,
  fetchurl,
  gfortran,
  nix-update-script,
  versionCheckHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "fortran-fpm";
  version = "0.13.0";

  src = fetchurl {
    url = "https://github.com/fortran-lang/fpm/releases/download/v${finalAttrs.version}/fpm-${finalAttrs.version}.F90";
    hash = "sha256-ABz/bPEUXyFbqgiIuieswGzqMKibedGovpfbP/+8jNI=";
  };

  nativeBuildInputs = [ gfortran ];

  buildPhase = ''
    runHook preBuild

    mkdir -p ${finalAttrs.buildPath}
    gfortran -J ${finalAttrs.buildPath} -o ${finalAttrs.buildPath}/fortran-fpm $src

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp ${finalAttrs.buildPath}/fortran-fpm $out/bin

    runHook postInstall
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  buildPath = "build/bootstrap";
  dontUnpack = true;

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Fortran Package Manager (fpm)";
    homepage = "https://fpm.fortran-lang.org";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.proofconstruction ];
    platforms = lib.platforms.all;
    mainProgram = "fortran-fpm";
  };
})
