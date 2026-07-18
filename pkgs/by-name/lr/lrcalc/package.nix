{
  lib,
  stdenv,
  autoreconfHook,
  fetchFromBitbucket,
  # Reverse dependency
  sage,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "lrcalc";
  version = "2.1";

  src = fetchFromBitbucket {
    owner = "asbuch";
    repo = "lrcalc";
    rev = "lrcalc-${finalAttrs.version}";
    sha256 = "0s3amf3z75hnrjyszdndrvk4wp5p630dcgyj341i6l57h43d1p4k";
  };

  nativeBuildInputs = [
    autoreconfHook
  ];

  doCheck = true;
  passthru.tests = { inherit sage; };

  meta = {
    description = "Littlewood-Richardson calculator";
    homepage = "http://math.rutgers.edu/~asbuch/lrcalc/";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.unix;
    teams = [ lib.teams.sage ];
  };
})
