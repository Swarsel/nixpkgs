{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  eigen,
  gitUpdater,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "poselib";
  version = "2.0.5";

  src = fetchFromGitHub {
    owner = "PoseLib";
    repo = "PoseLib";
    rev = "v${finalAttrs.version}";
    hash = "sha256-fARRKT2UoPuuk9FOOsBdrACwGiGXWg/mLV4R0QIjeak=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [ eigen ];
  passthru.updateScript = gitUpdater { rev-prefix = "v"; };

  meta = {
    description = "A collection of minimal solvers for camera pose estimation";
    homepage = "https://github.com/PoseLib/PoseLib";
    changelog = "https://github.com/PoseLib/PoseLib/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ usertam ];
    platforms = lib.platforms.unix;
  };
})
