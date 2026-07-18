{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  fetchpatch,
}:

stdenv.mkDerivation {
  pname = "safestringlib";
  # Latest release is 1.2.0 and has compilation issues
  version = "1.2.0-unstable-2024-10-21";

  src = fetchFromGitHub {
    owner = "intel";
    repo = "safestringlib";
    rev = "e99c03cfafdce5311c4dbf1fd3f916ccc6e300be";
    hash = "sha256-d+6YDtMtdaS2eW0eIfuwzdQRiExsoexL3fKj7C2zENM=";
  };

  outputs = [
    "out"
  ];

  patches = [
    # https://github.com/intel/safestringlib/issues/74
    (fetchpatch {
      hash = "sha256-4HS7XyKPQSmKczaMCi1s6NxgTNzRZXTds2CXBTbpuAM=";
      name = "darwin-fix";
      url = "https://github.com/intel/safestringlib/pull/75/commits/3ff9c6234be7dd4ee1dd5cdc2ccbb2c7541adfec.patch";
    })
  ];

  # see https://github.com/bwa-mem2/bwa-mem2/issues/93
  # Skip wmemset too
  postPatch = lib.optionalString stdenv.hostPlatform.isDarwin ''
    sed -i 's/memset_s/memset8_s/g' include/safe_mem_lib.h
    sed -i 's/memset_s/memset8_s/g' safeclib/memset16_s.c
    sed -i 's/memset_s/memset8_s/g' safeclib/memset32_s.c
    sed -i 's/memset_s/memset8_s/g' safeclib/memset_s.c
    sed -i 's/memset_s/memset8_s/g' safeclib/wmemset_s.c
    sed -i 's/ memset_s/ memset8_s/g' unittests/*.c
    sed -i 's/ wmemset_s/ wmemset8_s/g' unittests/*.c
  '';

  nativeBuildInputs = [ cmake ];

  cmakeFlags = [
    (lib.cmakeBool "BUILD_UNITTESTS" true)
    "-DCMAKE_POLICY_VERSION_MINIMUM=3.5"
  ];

  doCheck = true;

  checkPhase = ''
    runHook preCheck
    cd unittests
    ./safestring_test
    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib
    cp ../libsafestring_static.a $out/lib/libsafestring.a
    mkdir -p $out/
    cp -r ../../include  $out/

    runHook postInstall
  '';

  meta = {
    description = "Safer replacements for C library functions that prevent serious security vulnerabilities";
    homepage = "https://github.com/intel/safestringlib";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ apraga ];
    platforms = lib.platforms.unix;
  };
}
