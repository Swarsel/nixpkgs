{
  lib,
  stdenv,
  fetchFromGitLab,
  cmake,
  libcprime,
  libcsys,
  libmediainfo,
  libzen,
  ninja,
  qt6,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "coreinfo";
  version = "5.0.1";

  src = fetchFromGitLab {
    owner = "cubocore/coreapps";
    repo = "coreinfo";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Ct/vAxtdFcXIxleaePhWD5L42d88go/3arYKSrw/c2c=";
  };

  nativeBuildInputs = [
    cmake
    ninja
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    qt6.qtbase
    libzen
    libmediainfo
    zlib
    libcprime
    libcsys
  ];

  meta = {
    description = "File information tool from the C Suite";
    homepage = "https://gitlab.com/cubocore/coreapps/coreinfo";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "coreinfo";
  };
})
