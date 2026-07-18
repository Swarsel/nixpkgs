{
  extra-cmake-modules,
  fetchpatch,
  futuresql,
  kcoreaddons,
  kcrash,
  ki18n,
  kirigami,
  kirigami-addons,
  kwindowsystem,
  mkKdeDerivation,
  purpose,
  python3,
  qcoro,
  qtdeclarative,
  qtmultimedia,
  qtsvg,
}:
let
  ps = python3.pkgs;
  pythonDeps = [
    ps.yt-dlp
    ps.ytmusicapi
  ];
in
mkKdeDerivation {
  pname = "audiotube";

  extraBuildInputs = [
    qtdeclarative
    qtmultimedia
    qtsvg

    extra-cmake-modules
    futuresql
    kirigami
    kirigami-addons
    kcoreaddons
    ki18n
    kcrash
    kwindowsystem
    purpose
    qcoro
  ]
  ++ pythonDeps;

  extraNativeBuildInputs = [
    ps.pybind11
  ];

  qtWrapperArgs = [
    "--prefix PYTHONPATH : ${ps.makePythonPath pythonDeps}"
  ];

  meta.mainProgram = "audiotube";
}
