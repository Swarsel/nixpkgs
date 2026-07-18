{
  lib,
  stdenv,
  fetchurl,
  autoreconfHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libmd";
  version = "1.2.0";

  src = fetchurl {
    hash = "sha256-rBX/uEMFAvuszexmxagu4OqwsPNiIN9WcQ/q3+sT0KA=";

    urls = [
      "https://archive.hadrons.org/software/libmd/libmd-${finalAttrs.version}.tar.xz"
      "https://libbsd.freedesktop.org/releases/libmd-${finalAttrs.version}.tar.xz"
    ];
  };

  outputs = [
    "out"
    "dev"
    "man"
  ];

  nativeBuildInputs = [ autoreconfHook ];
  doCheck = true;
  enableParallelBuilding = true;

  meta = {
    # Git: https://git.hadrons.org/cgit/libmd.git
    description = "Message Digest functions from BSD systems";
    homepage = "https://www.hadrons.org/software/libmd/";
    changelog = "https://archive.hadrons.org/software/libmd/libmd-${finalAttrs.version}.announce";

    license = with lib.licenses; [
      bsd3
      bsd2
      isc
      beerware
      publicDomain
    ];

    maintainers = [ ];
    platforms = lib.platforms.unix;
  };
})
