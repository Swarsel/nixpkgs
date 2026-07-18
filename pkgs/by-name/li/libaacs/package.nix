{
  lib,
  stdenv,
  fetchurl,
  bison,
  flex,
  libgcrypt,
  libgpg-error,
}:

# library that allows libbluray to play AACS protected bluray disks
# libaacs does not infringe DRM's right or copyright. See the legal page of the website for more info.

# Info on how to use / obtain aacs keys:
# http://vlc-bluray.whoknowsmy.name/
# https://wiki.archlinux.org/index.php/BluRay

stdenv.mkDerivation (finalAttrs: {
  pname = "libaacs";
  version = "0.11.1";

  src = fetchurl {
    url = "https://get.videolan.org/libaacs/${finalAttrs.version}/libaacs-${finalAttrs.version}.tar.bz2";
    sha256 = "sha256-qIqg6+TJinf3rv/ZKrPvZKxUjGuCLoJIqLkmclvqCjk=";
  };

  nativeBuildInputs = [
    bison
    flex
  ];

  buildInputs = [
    libgcrypt
    libgpg-error
  ];

  meta = {
    description = "Library to access AACS protected Blu-Ray disks";
    homepage = "https://www.videolan.org/developers/libaacs.html";
    license = lib.licenses.lgpl21;
    maintainers = [ ];
    platforms = with lib.platforms; unix;
    mainProgram = "aacs_info";
  };
})
