{
  lib,
  stdenv,
  fetchFromGitHub,
  boost,
  catch2_3,
  cmake,
  fmt,
  mimalloc,
  ninja,
  python3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "sv-lang";
  version = "11.0";

  src = fetchFromGitHub {
    owner = "MikePopoloski";
    repo = "slang";
    tag = "v${finalAttrs.version}";
    hash = "sha256-popHzwX0qwv2POAl7/qX3e//OwJRXGtSl9xogpSn2LI=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    python3
    ninja
  ];

  buildInputs = [
    boost
    fmt
    mimalloc
    # though only used in tests, cmake will complain its absence when configuring
    catch2_3
  ];

  cmakeFlags = [
    # fix for https://github.com/NixOS/nixpkgs/issues/144170
    "-DCMAKE_INSTALL_INCLUDEDIR=include"
    "-DCMAKE_INSTALL_LIBDIR=lib"

    "-DSLANG_INCLUDE_TESTS=${if finalAttrs.finalPackage.doCheck then "ON" else "OFF"}"
  ];

  # TODO: a mysterious linker error occurs when building the unittests on darwin.
  # The error occurs when using catch2_3 in nixpkgs, not when fetching catch2_3 using CMake
  doCheck = !stdenv.hostPlatform.isDarwin;
  __structuredAttrs = true;

  meta = {
    description = "SystemVerilog compiler and language services";
    homepage = "https://github.com/MikePopoloski/slang";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ sharzy ];
    platforms = lib.platforms.all;
    mainProgram = "slang";
    broken = stdenv.hostPlatform.isDarwin;
  };
})
