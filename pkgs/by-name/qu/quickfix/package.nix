{
  lib,
  stdenv,
  fetchFromGitHub,
  autoconf,
  automake,
  fetchpatch,
  libtool,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "quickfix";
  version = "1.15.1";

  src = fetchFromGitHub {
    owner = "quickfix";
    repo = "quickfix";
    rev = "v${finalAttrs.version}";
    sha256 = "1fgpwgvyw992mbiawgza34427aakn5zrik3sjld0i924a9d17qwg";
  };

  patches = [
    # Improved C++17 compatibility
    (fetchpatch {
      sha256 = "1wlk4j0wmck0zm6a70g3nrnq8fz0id7wnyxn81f7w048061ldhyd";
      url = "https://github.com/quickfix/quickfix/commit/a46708090444826c5f46a5dbf2ba4b069b413c58.diff";
    })
    ./disableUnitTests.patch
  ];

  postPatch = ''
    substituteInPlace bootstrap --replace-fail glibtoolize libtoolize
  '';

  # autoreconfHook does not work
  nativeBuildInputs = [
    autoconf
    automake
    libtool
  ];

  preConfigure = ''
    ./bootstrap
  '';

  # More hacking out of the unittests
  preBuild = ''
    substituteInPlace Makefile --replace 'UnitTest++' ' '
  '';

  enableParallelBuilding = true;

  meta = {
    description = "C++ Fix Engine Library";
    homepage = "http://www.quickfixengine.org";
    license = lib.licenses.free; # similar to BSD 4-clause
    broken = stdenv.hostPlatform.isAarch64;
  };
})
