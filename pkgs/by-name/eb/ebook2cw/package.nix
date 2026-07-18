{
  lib,
  stdenv,
  fetchgit,
  fetchpatch,
  gettext,
  lame,
  libvorbis,
}:

stdenv.mkDerivation rec {
  pname = "ebook2cw";
  version = "0.8.4";

  src = fetchgit {
    url = "https://git.fkurz.net/dj1yfk/ebook2cw.git";
    rev = "${pname}-${version}";
    sha256 = "0h7lg59m3dcydzkc8szipnwzag8fqwwvppa9fspn5xqd4blpcjd5";
  };

  patches = [
    # Fixes non-GCC compilers and a missing directory in the install phase.
    (fetchpatch {
      sha256 = "1m5f819cj3fj1piss0a5ciib3jqrqdc14lp3i3dszw4bg9v1pgyd";
      url = "https://git.fkurz.net/dj1yfk/ebook2cw/commit/eb5742e70b042cf98a04440395c34390b171c035.patch";
    })
  ];

  buildInputs = [
    lame
    libvorbis
    gettext
  ];

  makeFlags = [ "DESTDIR=$(out)" ];

  meta = {
    description = "Convert ebooks to Morse MP3s/OGGs";
    homepage = "https://fkurz.net/ham/ebook2cw.html";
    license = lib.licenses.gpl2;
    maintainers = with lib.maintainers; [ earldouglas ];
    platforms = lib.platforms.all;
    mainProgram = "ebook2cw";
  };
}
