{
  lib,
  stdenv,
  cmake,
  fetchFromGitiles,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "aemu";
  version = "0.1.2";

  src = fetchFromGitiles {
    url = "https://android.googlesource.com/platform/hardware/google/aemu";
    rev = "v${finalAttrs.version}-aemu-release";
    hash = "sha256-8UMm2dXdvmX6rUn4wQWuqI8bamwgf0x/5BQT+7atzjY=";
  };

  patches = [
    # stop using transitional LFS64 APIs, which are removed in musl 1.2.4
    # https://android-review.googlesource.com/c/platform/hardware/google/aemu/+/3105640/1
    ./LFS64.patch
  ];

  nativeBuildInputs = [ cmake ];

  cmakeFlags = [
    "-DAEMU_COMMON_GEN_PKGCONFIG=ON"
    "-DAEMU_COMMON_BUILD_CONFIG=gfxstream"
    # "-DENABLE_VKCEREAL_TESTS=OFF"
  ];

  meta = {
    description = "Android emulation utilities library";
    homepage = "https://android.googlesource.com/platform/hardware/google/aemu";

    # The BSD license comes from host-common/VpxFrameParser.cpp, which
    # incorporates some code from libvpx, which uses the 3-clause BSD license.
    license = with lib.licenses; [
      asl20
      mit
      bsd3
    ];

    maintainers = with lib.maintainers; [ qyliss ];

    # See base/include/aemu/base/synchronization/Lock.h
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];
  };
})
