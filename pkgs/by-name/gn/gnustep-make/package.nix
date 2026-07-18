{
  lib,
  fetchurl,
  clangStdenv,
  gnustep-libobjc,
  which,
}:

clangStdenv.mkDerivation (finalAttrs: {
  pname = "gnustep-make";
  version = "2.9.3";

  src = fetchurl {
    url = "ftp://ftp.gnustep.org/pub/gnustep/core/gnustep-make-${finalAttrs.version}.tar.gz";
    sha256 = "sha256-k8oyC3BieevKU3YNqJ1MPyu8VH9HI5ZxQKNDRtnwTCQ=";
  };

  patches = [ ./fixup-paths.patch ];
  buildInputs = [ gnustep-libobjc ];
  propagatedBuildInputs = [ which ];

  configureFlags = [
    "--with-layout=fhs-system"
    "--disable-install-p"
  ];

  makeFlags = [
    "GNUSTEP_INSTALLATION_DOMAIN=SYSTEM"
  ];

  preConfigure = ''
    configureFlags="$configureFlags --with-config-file=$out/etc/GNUstep/GNUstep.conf"
  '';

  setupHook = ./setup-hook.sh;

  meta = {
    description = "Build manager for GNUstep";
    homepage = "https://gnustep.github.io/";

    changelog = "https://github.com/gnustep/tools-make/releases/tag/make-${
      builtins.replaceStrings [ "." ] [ "_" ] finalAttrs.version
    }";

    license = lib.licenses.lgpl2Plus;

    maintainers = with lib.maintainers; [
      ashalkhakov
      dblsaiko
    ];

    platforms = lib.platforms.unix;
  };
})
