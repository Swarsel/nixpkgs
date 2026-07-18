{
  lib,
  stdenv,
  fetchFromGitHub,
  # build and doc tooling
  asciidoctor,
  # build deps
  curl,
  doxygen,
  glibcLocales,
  graphviz,
  jdk,
  libedit,
  librist,
  openssl,
  python3,
  qpdf,
  ruby,
  srt,
  udevCheckHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "tsduck";
  version = "3.40-4165";

  src = fetchFromGitHub {
    owner = "tsduck";
    repo = "tsduck";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-bFnsGoElXeStIX5KwonJuF0x7DDzhzq+3oygkUOmZE0=";
  };

  # remove tests which break the sandbox
  patches = [ ./tests.patch ];

  postPatch = ''
    patchShebangs scripts
  '';

  nativeBuildInputs = [
    asciidoctor
    doxygen
    graphviz
    python3
    ruby
    qpdf
    udevCheckHook
  ];

  buildInputs = [
    curl
    glibcLocales
    jdk
    libedit
    librist
    openssl
    srt
  ];

  # see CONFIG.txt in the sources
  makeFlags = [
    "CXXFLAGS_NO_WARNINGS=-Wno-deprecated-declarations"
    "NODEKTEC=1"
    "NOGITHUB=1"
    "NOHIDES=1"
    "NOPCSC=1"
    "NOVATEK=1"
    "SYSPREFIX=/"
    "SYSROOT=${placeholder "out"}"
  ];

  doCheck = true;
  doInstallCheck = true;
  checkTarget = "test";
  enableParallelBuilding = true;

  installTargets = [
    "install-tools"
    "install-devel"
  ];

  meta = {
    description = "MPEG Transport Stream Toolkit";
    homepage = "https://github.com/tsduck/tsduck";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ siriobalmelli ];
    platforms = lib.platforms.all;
    mainProgram = "tsversion";
  };
})
