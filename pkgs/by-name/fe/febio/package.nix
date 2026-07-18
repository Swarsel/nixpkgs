{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  fetchpatch2,
  mkl,
  ninja,
  replaceVars,
  zlib,
  mklSupport ? true,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "FEBio";
  version = "4.8";

  src = fetchFromGitHub {
    owner = "febiosoftware";
    repo = "FEBio";
    rev = "v${finalAttrs.version}";
    hash = "sha256-x2QYnMMiGd2x2jvBMLBK7zdJv3yzYHkJ6a+0xes6OOk=";
  };

  patches = [
    # Fix library searching and installation
    (replaceVars ./fix-cmake.patch {
      so = stdenv.hostPlatform.extensions.sharedLibrary;
    })

    # Fixed missing header include for strcpy
    # https://github.com/febiosoftware/FEBio/pull/92
    (fetchpatch2 {
      hash = "sha256-/uLnJB/oAwLQnsZtJnUlaAEpyZVLG6o2riRwwMCH8rI=";
      url = "https://github.com/febiosoftware/FEBio/commit/ad9e80e2aa8737828855458a703822f578db2fd3.patch?full_index=1";
    })
  ];

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [ zlib ] ++ lib.optionals mklSupport [ mkl ];

  cmakeFlags = lib.optionals mklSupport [
    (lib.cmakeBool "USE_MKL" true)
    (lib.cmakeFeature "MKLROOT" "${mkl}")
  ];

  meta = {
    description = "Software tool for nonlinear finite element analysis in biomechanics and biophysics";
    homepage = "https://febio.org/";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ Scriptkiddi ];
    platforms = lib.platforms.unix;
  };
})
