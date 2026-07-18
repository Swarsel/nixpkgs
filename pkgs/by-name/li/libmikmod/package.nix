{
  lib,
  stdenv,
  fetchurl,
  alsa-lib,
  libpulseaudio,
  texinfo,
}:

let
  inherit (lib) optional optionalString;

in
stdenv.mkDerivation (finalAttrs: {
  pname = "libmikmod";
  version = "3.3.13";

  src = fetchurl {
    url = "mirror://sourceforge/mikmod/libmikmod-${finalAttrs.version}.tar.gz";
    sha256 = "sha256-n8F5n36mqVx8WILemL6F/H0gugpKb8rK4RyMazgrsgc=";
  };

  outputs = [
    "out"
    "dev"
    "man"
  ];

  buildInputs = [ texinfo ] ++ optional stdenv.hostPlatform.isLinux alsa-lib;
  propagatedBuildInputs = optional stdenv.hostPlatform.isLinux libpulseaudio;

  env = lib.optionalAttrs stdenv.hostPlatform.isLinux {
    NIX_LDFLAGS = "-lasound";
  };

  postInstall = ''
    moveToOutput bin/libmikmod-config "$dev"
  '';

  enableParallelBuilding = true;

  meta = {
    description = "Library for playing tracker music module files";

    longDescription = ''
      A library for playing tracker music module files supporting many formats,
      including MOD, S3M, IT and XM.
    '';

    homepage = "https://mikmod.shlomifish.org/";
    license = lib.licenses.lgpl2Plus;

    maintainers = [
    ];

    platforms = lib.platforms.unix;
    mainProgram = "libmikmod-config";
  };
})
