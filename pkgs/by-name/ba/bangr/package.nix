{
  lib,
  stdenv,
  fetchFromGitHub,
  cairo,
  cpio,
  libsndfile,
  libx11,
  lv2,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "bangr";
  version = "1.6.4";

  src = fetchFromGitHub {
    owner = "sjaehn";
    repo = "BAngr";
    tag = finalAttrs.version;
    sha256 = "sha256-od1UPriojDQHrAWzCYjuNoz27MRGIe+NvntUEFgGGWE=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    libx11
    cairo
    cpio
    lv2
    libsndfile
  ];

  installFlags = [ "PREFIX=$(out)" ];

  meta = {
    description = "Multi-dimensional dynamically distorted staggered multi-bandpass LV2 plugin";
    homepage = "https://github.com/sjaehn/BAngr";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.magnetophon ];
    platforms = lib.platforms.linux;
  };
})
