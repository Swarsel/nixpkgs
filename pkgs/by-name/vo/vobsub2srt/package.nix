{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  libtiff,
  pkg-config,
  tesseract3,
}:

stdenv.mkDerivation {
  pname = "vobsub2srt";
  version = "unstable-2014-08-17";

  src = fetchFromGitHub {
    owner = "ruediger";
    repo = "VobSub2SRT";
    rev = "a6abbd61127a6392d420bbbebdf7612608c943c2";
    sha256 = "sha256-i6V2Owb8GcTcWowgb/BmdupOSFsYiCF2SbC9hXa26uY=";
  };

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail "cmake_minimum_required(VERSION 2.6.4 FATAL_ERROR)" "cmake_minimum_required(VERSION 3.10)"
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [ libtiff ];
  propagatedBuildInputs = [ tesseract3 ];
  env.NIX_CFLAGS_COMPILE = toString (lib.optionals stdenv.cc.isGNU [ "-std=c++11" ]);

  meta = {
    description = "Converts VobSub subtitles into SRT subtitles";
    homepage = "https://github.com/ruediger/VobSub2SRT";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "vobsub2srt";
  };
}
