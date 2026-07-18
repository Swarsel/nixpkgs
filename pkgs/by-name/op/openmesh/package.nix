{
  lib,
  stdenv,
  fetchFromGitLab,
  cmake,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "openmesh";
  version = "11.0.0";

  src = fetchFromGitLab {
    owner = "OpenMesh";
    repo = "OpenMesh";
    rev = "OpenMesh-${lib.versions.majorMinor finalAttrs.version}";
    hash = "sha256-1FmAieCaskKaaAWjgEXr/CWpFxrhB2Rca1sXpxLrQHw=";
    fetchSubmodules = true;
    domain = "gitlab.vci.rwth-aachen.de:9000";
  };

  nativeBuildInputs = [ cmake ];

  meta = {
    description = "Generic and efficient polygon mesh data structure";
    homepage = "https://www.graphics.rwth-aachen.de/software/openmesh/";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ yzx9 ];
    platforms = lib.platforms.all;
  };
})
