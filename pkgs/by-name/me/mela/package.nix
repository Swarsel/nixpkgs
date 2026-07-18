{
  lib,
  stdenv,
  fetchFromGitHub,
  gfortran,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mela";
  version = "2.0.1";

  src = fetchFromGitHub {
    owner = "vbertone";
    repo = "MELA";
    rev = finalAttrs.version;
    sha256 = "01sgd4mwx4n58x95brphp4dskqkkx8434bvsr38r5drg9na5nc9y";
  };

  nativeBuildInputs = [ gfortran ];
  enableParallelBuilding = true;

  meta = {
    description = "Mellin Evolution LibrAry";
    homepage = "https://github.com/vbertone/MELA";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ veprbl ];
    platforms = lib.platforms.unix;
    mainProgram = "mela-config";
  };
})
