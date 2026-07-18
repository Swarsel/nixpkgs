{
  lib,
  stdenv,
  fetchFromGitLab,
  cmake,
  libcprime,
  libcsys,
  ninja,
  qt6,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "corefm";
  version = "5.0.0";

  src = fetchFromGitLab {
    owner = "cubocore/coreapps";
    repo = "corefm";
    tag = "v${finalAttrs.version}";
    hash = "sha256-VsnbWknkMJp/2MDXbJuEQomotGqTXhZcUvu+ODJOjdM=";
  };

  nativeBuildInputs = [
    cmake
    ninja
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    qt6.qtbase
    libcprime
    libcsys
  ];

  meta = {
    description = "Lightwight filemanager from the C Suite";
    homepage = "https://gitlab.com/cubocore/coreapps/corefm";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "corefm";
  };
})
