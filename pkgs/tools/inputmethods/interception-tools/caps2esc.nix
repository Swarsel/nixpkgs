{
  lib,
  stdenv,
  fetchFromGitLab,
  cmake,
  fetchpatch,
}:

stdenv.mkDerivation rec {
  pname = "caps2esc";
  version = "0.3.2";

  src = fetchFromGitLab {
    owner = "linux/plugins";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-gPFElAixiDTTwcl2XKM7MbTkpRrg8ToO5K7H8kz3DHk=";
    group = "interception";
  };

  patches = [
    (fetchpatch {
      sha256 = "sha256-lB+pDwmFWW1fpjOPC6GLpxvrs87crDCNk1s9KnfrDD4=";
      url = "https://gitlab.com/interception/linux/plugins/caps2esc/-/commit/47ea8022df47b23d5d9603f9fe71b3715e954e4c.patch";
    })
  ];

  nativeBuildInputs = [ cmake ];

  meta = {
    description = "Transforming the most useless key ever into the most useful one";
    homepage = "https://gitlab.com/interception/linux/plugins/caps2esc";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "caps2esc";
  };
}
