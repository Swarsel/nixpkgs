{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  fetchpatch,
  libexif,
  libintl,
  pkg-config,
  popt,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "exif";
  version = "0.6.22";

  src = fetchFromGitHub {
    owner = "libexif";
    repo = "exif";
    rev = "exif-${builtins.replaceStrings [ "." ] [ "_" ] finalAttrs.version}-release";
    sha256 = "1xlb1gdwxm3rmw7vlrynhvjp9dkwmvw23mxisdbdmma7ah2nda3i";
  };

  patches = [
    (fetchpatch {
      name = "CVE-2021-27815.part-1.patch";
      sha256 = "0mfx7l8w3w1c2mn5h5d6s7gdfyd91wnml8v0f19v5sdn70hx5aa4";
      url = "https://github.com/libexif/exif/commit/f6334d9d32437ef13dc902f0a88a2be0063d9d1c.patch";
    })
    (fetchpatch {
      name = "CVE-2021-27815.part-2.patch";
      sha256 = "11lyvy20maisiyhxgxvm85v5l5ba7p0bpd4m0g4ryli32mrwwy0l";
      url = "https://github.com/libexif/exif/commit/eb84b0e3c5f2a86013b6fcfb800d187896a648fa.patch";
    })
  ];

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    libexif
    popt
    libintl
  ];

  meta = {
    description = "Utility to read and manipulate EXIF data in digital photographs";
    homepage = "https://libexif.github.io";
    license = lib.licenses.lgpl21Plus;
    platforms = lib.platforms.unix;
    mainProgram = "exif";
  };
})
