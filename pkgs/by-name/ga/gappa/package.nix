{
  lib,
  stdenv,
  fetchurl,
  bison,
  boost,
  flex,
  gmp,
  mpfr,
  nix-update-script,
  versionCheckHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gappa";
  version = "1.8.0";

  src = fetchurl {
    url = "https://gappa.gitlabpages.inria.fr/releases/gappa-${finalAttrs.version}.tar.gz";
    hash = "sha256-dA1gOwRkW7lEo04bMldFHX0Chs8gMbd0Yl4/HhYK4qo";
  };

  # For darwin sandboxed builds
  postPatch = ''
    substituteInPlace remake.cpp \
      --replace 'tempnam(NULL, "rmk-")' 'tempnam(".", "rmk-")'
  '';

  strictDeps = true;

  nativeBuildInputs = [
    flex
    bison
  ];

  buildInputs = [
    gmp
    mpfr
    boost.dev
  ];

  buildPhase = ''
    runHook preBuild

    ./remake

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    ./remake install

    runHook postInstall
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Verifying and formally proving properties on numerical programs dealing with floating-point or fixed-point arithmetic";
    homepage = "https://gappa.gitlabpages.inria.fr/";

    license = with lib.licenses; [
      cecill21
      gpl3
    ];

    maintainers = with lib.maintainers; [ vbgl ];
    platforms = lib.platforms.all;
    mainProgram = "gappa";
  };
})
