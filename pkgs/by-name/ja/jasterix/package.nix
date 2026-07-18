{
  lib,
  stdenv,
  fetchFromGitHub,
  boost,
  catch2_3,
  cmake,
  fetchpatch,
  libarchive,
  libpcap,
  log4cpp,
  onetbb,
  openssl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "jasterix";
  version = "0.1.4";

  src = fetchFromGitHub {
    owner = "OpenATSGmbH";
    repo = "jASTERIX";
    tag = "v${finalAttrs.version}";
    hash = "sha256-df5tByZwtQLdV0UlSo1WkgyoF3hReU/mN74V2WL6zoI=";
  };

  outputs = [
    "out"
    "dev"
  ];

  patches = [
    (fetchpatch {
      hash = "sha256-V0/nMJGb8ZB/Z6bKvyZnic57HXAsUAHXgyVq+D4yFDw=";
      name = "jasterix-fix-tests.patch";
      url = "https://github.com/OpenATSGmbH/jASTERIX/commit/b79e59c042ebb7eee31f50a7ed48840bcec50429.patch";
    })
  ];

  # Disable boost-stacktrace_backtrace, which is an optional dependency and not yet available in Nix.
  postPatch = ''
    sed -i 's/\(find_package .*\) stacktrace_backtrace/\1/' CMakeLists.txt
    sed -i 's/BOOST_STACKTRACE_USE_BACKTRACE/#BOOST_STACKTRACE_USE_BACKTRACE/' CMakeLists.txt
    sed -i 's/BOOST_STACKTRACE_LINK/#BOOST_STACKTRACE_LINK/' CMakeLists.txt
  '';

  strictDeps = true;
  nativeBuildInputs = [ cmake ];

  buildInputs = [
    boost.dev
    catch2_3
    libarchive.dev
    libpcap
    log4cpp
    onetbb.dev
    openssl.dev
  ];

  cmakeFlags = [
    (lib.cmakeBool "BUILD_SHARED" (!stdenv.hostPlatform.isStatic))
    (lib.cmakeBool "BUILD_STATIC" stdenv.hostPlatform.isStatic)
    (lib.cmakeBool "WITH_UNIT_TESTS" finalAttrs.doCheck)
  ];

  doCheck = true;
  __structuredAttrs = true;

  meta = {
    description = "C++ Library for EUROCONTROL's ASTERIX to JSON conversion";
    homepage = "https://github.com/OpenATSGmbH/jASTERIX";
    changelog = "https://github.com/OpenATSGmbH/jASTERIX/releases/tag/v${finalAttrs.src.tag}";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.vog ];
    platforms = lib.platforms.all;
  };
})
