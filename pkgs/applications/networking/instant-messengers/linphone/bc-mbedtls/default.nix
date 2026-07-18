{
  lib,
  stdenv,
  fetchFromGitLab,
  cmake,
  fetchpatch,
  ninja,
  perl, # Project uses Perl for scripting and testing
  python3,
}:
let
  rev = "1d452d3852321cb55c07307cb506b25759134b76";
in
stdenv.mkDerivation {
  pname = "mbedtls";
  # taken from `ChangeLog`
  version = "3.6.1-unstable-2025-08-11";

  src = fetchFromGitLab {
    inherit rev;
    owner = "public/external";
    repo = "mbedtls";
    sha256 = "sha256-jQpRn2F21sPKKAiaqsUvaKyuR80AnedG/hAyiNamKjc=";
    fetchSubmodules = true;
    domain = "gitlab.linphone.org";
    group = "BC";
  };

  patches = [
    # Fix build with gcc15
    # https://www.github.com/Mbed-TLS/mbedtls/pull/10215
    (fetchpatch {
      excludes = [ "ChangeLog.d/unterminated-string-initialization.txt" ];
      hash = "sha256-hh2cGzL75fEqlFNhEyL2fI9qsBW2Eq43DdWFD9qLsKE=";
      name = "linphone-mbedtls-fix-unterminated-string-initialization.patch";
      url = "https://github.com/Mbed-TLS/mbedtls/commit/d593c54b3cbfc3c806476a725e7d82763da0da9e.patch";
    })
  ];

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    ninja
    perl
    python3
  ];

  cmakeFlags = [
    # tests don't compile, due to how BC sets up threading
    "-DENABLE_TESTING=OFF"
    "-DENABLE_PROGRAMS=OFF"

    "-DUSE_SHARED_MBEDTLS_LIBRARY=${if stdenv.hostPlatform.isStatic then "off" else "on"}"

    # Avoid a dependency on jsonschema and jinja2 by not generating source code
    # using python. In releases, these generated files are already present in
    # the repository and do not need to be regenerated. See:
    # https://github.com/Mbed-TLS/mbedtls/releases/tag/v3.3.0 below "Requirement changes".
    "-DGEN_FILES=off"
  ];

  # Parallel checking causes test failures
  # https://github.com/Mbed-TLS/mbedtls/issues/4980
  enableParallelChecking = false;
  # trivialautovarinit on clang causes test failures
  hardeningDisable = lib.optional stdenv.cc.isClang "trivialautovarinit";

  meta = {
    description = "Portable cryptographic and TLS library, formerly known as PolarSSL (Linphone fork)";
    homepage = "https://gitlab.linphone.org/BC/public/external/mbedtls";
    changelog = "https://gitlab.linphone.org/BC/public/external/mbedtls/-/blob/${rev}/ChangeLog";

    license = with lib.licenses; [
      asl20 # or
      gpl2Plus
    ];

    maintainers = with lib.maintainers; [ naxdy ];
    platforms = lib.platforms.all;
  };
}
