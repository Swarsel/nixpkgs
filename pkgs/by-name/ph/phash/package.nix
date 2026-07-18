{
  lib,
  stdenv,
  fetchFromGitHub,
  cimg,
  imagemagick,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "pHash";
  version = "0.9.6";

  src = fetchFromGitHub {
    owner = "clearscene";
    repo = "pHash";
    rev = finalAttrs.version;
    sha256 = "sha256-frISiZ89ei7XfI5F2nJJehfQZsk0Mlb4n91q/AiZ2vA=";
  };

  patches = [
    # proper pthread return value (https://github.com/clearscene/pHash/pull/20)
    ./0001-proper-pthread-return-value.patch
  ];

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ cimg ];
  # CImg.h calls to external binary `convert` from the `imagemagick` package
  # at runtime
  propagatedBuildInputs = [ imagemagick ];

  configureFlags = [
    "--enable-video-hash=no"
    "--enable-audio-hash=no"
  ];

  env.NIX_LDFLAGS = "-lfftw3_threads";

  postInstall = ''
    cp ${cimg}/include/CImg.h $out/include/
  '';

  meta = {
    description = "Compute the perceptual hash of an image";
    homepage = "http://www.phash.org";
    license = lib.licenses.gpl3;
    maintainers = [ lib.maintainers.imalsogreg ];
    platforms = lib.platforms.all;
    downloadPage = "https://github.com/clearscene/pHash";
  };
})
