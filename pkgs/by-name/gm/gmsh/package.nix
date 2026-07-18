{
  lib,
  stdenv,
  fetchurl,
  blas,
  cmake,
  copyDesktopItems,
  fltk,
  gfortran,
  gmm,
  lapack,
  libGL,
  libGLU,
  libice,
  libjpeg,
  libsm,
  libx11,
  libxcursor,
  libxext,
  libxfixes,
  libxft,
  libxinerama,
  libxrender,
  llvmPackages,
  makeDesktopItem,
  opencascade-occt,
  python3Packages,
  zlib,
  enablePython ? false,
}:

assert (!blas.isILP64) && (!lapack.isILP64);

stdenv.mkDerivation (finalAttrs: {
  pname = "gmsh";
  version = "4.15.0";

  src = fetchurl {
    url = "https://gmsh.info/src/gmsh-${finalAttrs.version}-source.tgz";
    hash = "sha256-q7JjJxW9fQEw3tcUT9YmNjXNfeqIO432G6TaWM5qHf4=";
  };

  nativeBuildInputs = [
    cmake
    gfortran
  ]
  ++ lib.optional (
    enablePython && stdenv.buildPlatform == stdenv.hostPlatform
  ) python3Packages.pythonImportsCheckHook
  ++ lib.optional stdenv.hostPlatform.isLinux copyDesktopItems;

  buildInputs = [
    blas
    lapack
    gmm
    fltk
    libjpeg
    zlib
    opencascade-occt
  ]
  ++ lib.optionals (!stdenv.hostPlatform.isDarwin) [
    libGL
    libGLU
    libxrender
    libxcursor
    libxfixes
    libxext
    libxft
    libxinerama
    libx11
    libsm
    libice
  ]
  ++ lib.optional stdenv.cc.isClang llvmPackages.openmp;

  # N.B. the shared object is used by bindings
  cmakeFlags = [
    "-DENABLE_BUILD_SHARED=ON"
    "-DENABLE_BUILD_DYNAMIC=ON"
    "-DENABLE_OPENMP=ON"
  ];

  doCheck = true;

  postInstall =
    let
      logo = fetchurl {
        hash = "sha256-p69Cju3bn1ShWmESOSOmJj0x3IYDGI9oD25SFTh2GLo=";
        url = "https://salsa.debian.org/science-team/gmsh/-/raw/d2d8b4e3488c7b0f51879f809f624b537b4bd28f/debian/gmsh.svg";
      };
    in
    lib.optionalString stdenv.hostPlatform.isLinux ''
      install -Dm644 ${logo} $out/share/icons/hicolor/scalable/apps/gmsh.svg
    ''
    + lib.optionalString enablePython ''
      mkdir -p $out/${python3Packages.python.sitePackages}
      mv $out/lib/gmsh.py $out/${python3Packages.python.sitePackages}
      mv $out/lib/*.dist-info $out/${python3Packages.python.sitePackages}
    '';

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "Science"
        "Math"
      ];

      comment = finalAttrs.meta.description;
      desktopName = "Gmsh";
      exec = "gmsh";
      genericName = "3D Mesh Generator";
      icon = "gmsh";
      name = "gmsh";
    })
  ];

  pythonImportsCheck = [ "gmsh" ];

  meta = {
    description = "Three-dimensional finite element mesh generator";
    homepage = "https://gmsh.info/";
    changelog = "https://gitlab.onelab.info/gmsh/gmsh/-/releases/gmsh_${lib.concatStringsSep "_" (lib.versions.splitVersion finalAttrs.version)}#changelog";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    mainProgram = "gmsh";
  };
})
