{
  lib,
  stdenv,
  fetchFromGitHub,
  boost,
  cmake,
  python3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cryptominisat";
  version = "5.11.21";

  src = fetchFromGitHub {
    owner = "msoos";
    repo = "cryptominisat";
    rev = finalAttrs.version;
    hash = "sha256-8oH9moMjQEWnQXKmKcqmXuXcYkEyvr4hwC1bC4l26mo=";
  };

  # musl does not have sys/unistd.h
  postPatch = ''
    substituteInPlace src/picosat/picosat.c --replace-fail '<sys/unistd.h>' '<unistd.h>'
  '';

  strictDeps = true;

  nativeBuildInputs = [
    python3
    cmake
  ];

  buildInputs = [ boost ];

  meta = {
    description = "Advanced SAT Solver";
    homepage = "https://github.com/msoos/cryptominisat";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ mic92 ];
    platforms = lib.platforms.unix;
    mainProgram = "cryptominisat5";
  };
})
