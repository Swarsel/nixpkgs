{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  perl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "bdf2psf";
  version = "1.248";

  src = fetchurl {
    url = "mirror://debian/pool/main/c/console-setup/bdf2psf_${finalAttrs.version}_all.deb";
    sha256 = "sha256-51PE9o1kmISd/kYHLm8NUBDKi2eyXJkL0MkWlp1f8co=";
  };

  nativeBuildInputs = [ dpkg ];

  installPhase = ''
    runHook preInstall
    substituteInPlace usr/bin/bdf2psf --replace /usr/bin/perl "${perl}/bin/perl"
    rm usr/share/doc/bdf2psf/changelog.gz
    mv usr "$out"
    runHook postInstall
  '';

  dontBuild = true;
  dontConfigure = true;

  meta = {
    description = "BDF to PSF converter";

    longDescription = ''
      Font converter to generate console fonts from BDF source fonts
    '';

    homepage = "https://packages.debian.org/sid/bdf2psf";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ rnhmjoj ];
    platforms = lib.platforms.all;
    mainProgram = "bdf2psf";
  };
})
