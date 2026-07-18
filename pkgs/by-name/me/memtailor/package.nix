{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  gtest,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "memtailor";
  version = "1.4";

  src = fetchFromGitHub {
    owner = "Macaulay2";
    repo = "memtailor";
    tag = "v${finalAttrs.version}";
    hash = "sha256-cpM/oa4GAKDxs6yrxHngpvam18cGA2u9Ftvd2WW4vdI=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    autoreconfHook
  ];

  configureFlags = [
    (lib.withFeature finalAttrs.doCheck "gtest")
  ];

  doCheck = true;

  checkInputs = [
    gtest
  ];

  __structuredAttrs = true;
  enableParallelBuilding = true;

  meta = {
    description = "C++ library of special purpose memory allocators";

    longDescription = ''
      Memtailor is a C++ library of special purpose memory allocators. It
      currently offers an arena allocator and a memory pool.

      The main motivation to use a memtailor allocator is better and more
      predictable performance than you get with new/delete. Sometimes a
      memtailor allocator can also be more convenient due to the ability to
      free many allocations at one time.
    '';

    homepage = "https://github.com/Macaulay2/memtailor";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ coolcuber ];
    platforms = lib.platforms.unix;
  };
})
