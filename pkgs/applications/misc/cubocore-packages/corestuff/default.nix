{
  lib,
  stdenv,
  fetchFromGitLab,
  cmake,
  kdePackages,
  libcprime,
  libcsys,
  libxcomposite,
  ninja,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "corestuff";
  version = "5.0.0";

  src = fetchFromGitLab {
    owner = "cubocore/coreapps";
    repo = "corestuff";
    tag = "v${finalAttrs.version}";
    hash = "sha256-/EI7oM7c7GKEQ+XQSiWwkJ7uNrJkxgLXEXZ6r5Jqh70=";
  };

  patches = [
    # Remove autostart
    ./0001-fix-installPhase.patch
  ];

  nativeBuildInputs = [
    cmake
    ninja
    kdePackages.wrapQtAppsHook
  ];

  buildInputs = [
    kdePackages.qtbase
    kdePackages.kglobalaccel
    libxcomposite
    libcprime
    libcsys
  ];

  meta = {
    description = "Activity viewer from the C Suite";
    homepage = "https://gitlab.com/cubocore/coreapps/corestuff";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "corestuff";
    # Address boundary error
    broken = true;
  };
})
