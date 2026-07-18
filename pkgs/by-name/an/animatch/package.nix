{
  lib,
  stdenv,
  fetchFromGitLab,
  allegro5,
  cmake,
  libGL,
  libx11,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "animatch";
  version = "1.0.3";

  src = fetchFromGitLab {
    owner = "HolyPangolin";
    repo = "animatch";
    tag = "v${finalAttrs.version}";
    hash = "sha256-zBV45WMAXtCpPPbDpr04K/a9UtZ4KLP9nUauBlbhrFo=";
    fetchSubmodules = true;
  };

  postPatch = ''
    substituteInPlace libsuperderpy/src/3rdparty/cimgui/CMakeLists.txt --replace-fail \
      'cmake_minimum_required(VERSION 3.1)' \
      'cmake_minimum_required(VERSION 4.0)'
  '';

  strictDeps = true;

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    allegro5
    libGL
    libx11
  ];

  cmakeFlags = [
    "-DLIBSUPERDERPY_STATIC=ON" # recommended by upstream for coexistence with other superderpy games
  ];

  meta = {
    description = "Cute match three game for the Librem 5 smartphone";
    homepage = "https://gitlab.com/HolyPangolin/animatch/";
    license = with lib.licenses; [ gpl3Plus ];
    maintainers = with lib.maintainers; [ colinsane ];
    mainProgram = "animatch";
  };
})
