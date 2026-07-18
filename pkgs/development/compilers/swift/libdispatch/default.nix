{
  lib,
  stdenv,
  callPackage,
  cmake,
  fetchpatch,
  ninja,
  swift,
  useSwift ? true,
}:

let
  sources = callPackage ../sources.nix { };
in
stdenv.mkDerivation {
  inherit (sources) version;
  pname = "swift-corelibs-libdispatch";
  src = sources.swift-corelibs-libdispatch;

  outputs = [
    "out"
    "dev"
    "man"
  ];

  patches = [
    # Fix the build with modern Clang.
    (fetchpatch {
      hash = "sha256-wPZQ4wtEWk8HaKMfzjamlU6p/IW5EFiTssY63rGM+ZA=";
      url = "https://github.com/swiftlang/swift-corelibs-libdispatch/commit/30bb8019ba79cdae0eb1dc0c967c17996dd5cc0a.patch";
    })
    (fetchpatch {
      hash = "sha256-GABwDeTjciV36Sa0FS10mCfFCqRoBBstgW/OiKdPahA=";
      url = "https://github.com/swiftlang/swift-corelibs-libdispatch/commit/38872e2d44d66d2fb94186988509defc734888a5.patch";
    })

    ./disable-swift-overlay.patch
  ];

  nativeBuildInputs = [
    cmake
  ]
  ++ lib.optionals useSwift [
    ninja
    swift
  ];

  cmakeFlags = lib.optional useSwift "-DENABLE_SWIFT=ON";

  postInstall = ''
    # Provide a CMake module. This is primarily used to glue together parts of
    # the Swift toolchain. Modifying the CMake config to do this for us is
    # otherwise more trouble.
    mkdir -p $dev/lib/cmake/dispatch
    export dylibExt="${stdenv.hostPlatform.extensions.sharedLibrary}"
    substituteAll ${./glue.cmake} $dev/lib/cmake/dispatch/dispatchConfig.cmake
  '';

  meta = {
    description = "Grand Central Dispatch";
    homepage = "https://github.com/apple/swift-corelibs-libdispatch";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ cmm ];
    platforms = lib.platforms.linux;
    teams = [ lib.teams.swift ];
  };
}
