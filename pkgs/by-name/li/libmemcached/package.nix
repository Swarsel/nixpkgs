{
  lib,
  stdenv,
  fetchFromGitHub,
  bison,
  cmake,
  ctestCheckHook,
  cyrus_sasl,
  fetchpatch,
  flex,
  libevent,
  memcached,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libmemcached";
  version = "1.1.4";

  src = fetchFromGitHub {
    owner = "awesomized";
    repo = "libmemcached";
    tag = finalAttrs.version;
    hash = "sha256-jEw6L2/139oo4sGprl9Xp0DTarxAK1bEF2ak2kHWSAs=";
  };

  patches = lib.optionals stdenv.hostPlatform.isDarwin [
    (fetchpatch {
      hash = "sha256-aH51O4UM3M4yzTtC8bTy+6NKrtPfgqysrvspMZ/gWDc=";
      includes = [ "test/lib/random.cpp" ];
      name = "libcxx-compat.patch";
      url = "https://github.com/awesomized/libmemcached/commit/547460c12287a34a5993045157a0e13e14203f92.patch";
    })
  ];

  nativeBuildInputs = [
    bison
    cmake
    flex
  ];

  buildInputs = [ libevent ];
  propagatedBuildInputs = [ cyrus_sasl ];

  cmakeFlags = [
    (lib.cmakeBool "BUILD_TESTING" finalAttrs.doCheck)
    "-DENABLE_SASL=ON"
  ];

  doCheck = true;

  nativeCheckInputs = [
    ctestCheckHook
    memcached
  ];

  disabledTests = [
    "bin/memcapable"
    "memcached_regression_lp583031"
  ];

  meta = {
    description = "Open source C/C++ client library and tools for the memcached server";
    homepage = "https://github.com/awesomized/libmemcached";
    changelog = "https://github.com/awesomized/libmemcached/blob/${finalAttrs.src.tag}/ChangeLog-${lib.versions.majorMinor finalAttrs.version}.md";
    license = lib.licenses.bsd3;
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
})
