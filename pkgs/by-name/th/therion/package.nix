{
  lib,
  stdenv,
  fetchFromGitHub,
  catch2,
  cmake,
  curl,
  expat,
  fmt,
  freetype,
  gettext,
  libGL,
  libGLU,
  libjpeg,
  libtiff,
  makeWrapper,
  perl,
  pkg-config,
  proj,
  python3,
  sqlite,
  survex,
  tcl,
  tclPackages,
  texliveTeTeX,
  tk,
  vtk,
  wxwidgets_3_2,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "therion";
  version = "6.4.0";

  src = fetchFromGitHub {
    owner = "therion";
    repo = "therion";
    tag = "v${finalAttrs.version}";
    hash = "sha256-TiyoNYk+wWXyNytQwr5EfRSWzNc42LX3qjMV9M+dsx0=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    perl
    python3
    texliveTeTeX
    makeWrapper
    tcl.tclPackageHook
  ];

  buildInputs = [
    expat
    tclPackages.tkimg
    proj
    wxwidgets_3_2
    vtk
    tk
    freetype
    libjpeg
    gettext
    libGL
    libGLU
    sqlite
    libtiff
    curl
    fmt
    tcl
    tclPackages.tcllib
    tclPackages.bwidget
    catch2
  ];

  cmakeFlags = [
    "-DBUILD_THBOOK=OFF"
  ];

  preConfigure = ''
    export OUTDIR=$out
  '';

  fixupPhase = ''
    runHook preFixup

    wrapProgram $out/bin/therion \
      --prefix PATH : ${
        lib.makeBinPath [
          survex
          texliveTeTeX
        ]
      }
    wrapProgram $out/bin/xtherion \
      --prefix PATH : ${lib.makeBinPath [ tk ]}

    runHook postFixup
  '';

  meta = {
    description = "Cave surveying software";
    homepage = "https://therion.speleo.sk/";
    changelog = "https://github.com/therion/therion/blob/${finalAttrs.src.rev}/CHANGES";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ matthewcroughan ];
  };
})
