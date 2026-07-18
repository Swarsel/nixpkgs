{
  lib,
  stdenv,
  fetchFromGitHub,
  autoconf,
  automake,
  fetchpatch,
  gnulib,
  perl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "lbzip2";
  version = "2.5";

  src = fetchFromGitHub {
    owner = "kjn";
    repo = "lbzip2";
    rev = "v${finalAttrs.version}";
    sha256 = "1h321wva6fp6khz6x0i6rqb76xh327nw6v5jhgjpcckwdarj5jv8";
  };

  patches = [
    # This avoids an implicit function declaration when building gnulib's
    # xmalloc.c, addressing a build failure with future compiler version.
    # https://github.com/kjn/lbzip2/pull/33
    (fetchpatch {
      hash = "sha256-YNgmkh4bksIq5kBgZP+8o97aMm9CzFZldfUW6L5DGXk=";
      name = "GNULIB_XALLOC_DIE.patch";
      url = "https://github.com/kjn/lbzip2/commit/32b5167940ec817e454431956040734af405a9de.patch";
    })
  ];

  nativeBuildInputs = [
    autoconf
    automake
  ];

  buildInputs = [
    gnulib
    perl
  ];

  preConfigure = ''
    substituteInPlace configure.ac --replace 'AC_PREREQ([2.63])' 'AC_PREREQ(2.64)'
    ./build-aux/autogen.sh
  '';

  meta = {
    description = "Parallel bzip2 compression utility";
    homepage = "https://github.com/kjn/lbzip2"; # Formerly http://lbzip2.org/
    license = lib.licenses.gpl3;
    maintainers = [ ];
    platforms = lib.platforms.unix;
  };
})
