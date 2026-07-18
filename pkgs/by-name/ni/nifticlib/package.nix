{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "nifticlib";
  version = "3.0.1";

  src = fetchFromGitHub {
    owner = "NIFTI-Imaging";
    repo = "nifti_clib";
    rev = "v${finalAttrs.version}";
    sha256 = "0hamm6nvbjdjjd5md4jahzvn5559frigxaiybnjkh59ckxwb1hy4";
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [ zlib ];
  cmakeFlags = [ "-DDOWNLOAD_TEST_DATA=OFF" ];
  doCheck = true;

  checkPhase = ''
    runHook preCheck
    ctest -LE 'NEEDS_DATA'
    runHook postCheck
  '';

  meta = {
    description = "Medical imaging format C API";
    homepage = "https://nifti-imaging.github.io";
    license = lib.licenses.publicDomain;
    maintainers = with lib.maintainers; [ bcdarwin ];
    platforms = lib.platforms.unix;
  };
})
