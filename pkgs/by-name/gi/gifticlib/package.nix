{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ctestCheckHook,
  expat,
  nifticlib,
  zlib,
}:

stdenv.mkDerivation {
  pname = "gifticlib";
  version = "0-unstable-2020-07-07";

  src = fetchFromGitHub {
    owner = "NIFTI-Imaging";
    repo = "gifti_clib";
    rev = "5eae81ba1e87ef3553df3b6ba585f12dc81a0030";
    sha256 = "0gcab06gm0irjnlrkpszzd4wr8z0fi7gx8f7966gywdp2jlxzw19";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    expat
    nifticlib
    zlib
  ];

  cmakeFlags = [
    "-DUSE_SYSTEM_NIFTI=ON"
    "-DDOWNLOAD_TEST_DATA=OFF"
  ];

  # without the test data, this is only a few basic tests
  doCheck = !stdenv.hostPlatform.isDarwin;
  nativeCheckInputs = [ ctestCheckHook ];

  checkFlags = [
    "-LE"
    "NEEDS_DATA"
  ];

  meta = {
    description = "Medical imaging geometry format C API";
    homepage = "https://www.nitrc.org/projects/gifti";
    license = lib.licenses.publicDomain;
    maintainers = with lib.maintainers; [ bcdarwin ];
    platforms = lib.platforms.unix;
  };
}
