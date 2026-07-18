{
  lib,
  stdenv,
  fetchurl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "tinycompress";
  version = "1.2.13";

  src = fetchurl {
    url = "mirror://alsa/tinycompress/tinycompress-${finalAttrs.version}.tar.bz2";
    hash = "sha256-Dv5svXv/MZg+DUFt8ENnZ2ZcxM1w0njAbODoPg7qtds=";
  };

  meta = {
    description = "Userspace library for anyone who wants to use the ALSA compressed APIs";
    homepage = "http://www.alsa-project.org/";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ k900 ];
    platforms = lib.platforms.linux;
  };
})
