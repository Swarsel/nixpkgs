{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ta-lib";
  version = "0.7.1";

  src = fetchFromGitHub {
    owner = "TA-Lib";
    repo = "ta-lib";
    tag = "v${finalAttrs.version}";
    hash = "sha256-tme5YuTWdf4lCsWXF97kSeka7Vmqte0vTjwtaUNN+kA=";
  };

  nativeBuildInputs = [ autoreconfHook ];

  meta = {
    description = "Add technical analysis to your own financial market trading applications";
    homepage = "https://ta-lib.org/";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ rafael ];
    platforms = lib.platforms.linux;
    mainProgram = "ta-lib-config";
  };
})
