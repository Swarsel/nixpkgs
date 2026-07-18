{
  lib,
  stdenv,
  cmake,
  fetchgit,
  fetchpatch,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libuecc";
  version = "7";

  src = fetchgit {
    url = "git://git.universe-factory.net/libuecc";
    tag = "v${finalAttrs.version}";
    sha256 = "1sm05aql75sh13ykgsv3ns4x4zzw9lvzid6misd22gfgf6r9n5fs";
  };

  patches = [
    # Backport CMake 4 support
    (fetchpatch {
      hash = "sha256-3h+LC5JlSXNiJlEQxSQzC7+5s+nMp+ll2NQQC5HzTf0=";
      url = "https://github.com/neocturne/libuecc/commit/b3812bf5ab1777193c4b85863311c33997d141f9.patch";
    })
  ];

  nativeBuildInputs = [ cmake ];

  meta = {
    description = "Very small Elliptic Curve Cryptography library";
    homepage = "https://git.universe-factory.net/libuecc";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ fpletz ];
    platforms = lib.platforms.unix;
  };
})
