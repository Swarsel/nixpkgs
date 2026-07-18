{
  lib,
  stdenv,
  fetchFromGitHub,
  automaticcomponenttoolkit,
  cmake,
  fast-float,
  fetchpatch,
  gtest,
  libuuid,
  libzip,
  ninja,
  nix-update-script,
  openssl,
  pkg-config,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "lib3mf";
  version = "2.5.0";

  src = fetchFromGitHub {
    owner = "3MFConsortium";
    repo = "lib3mf";
    tag = "v${finalAttrs.version}";
    hash = "sha256-8S892kvea6c9RynfVHo7epBjT9cWCV4VchGZ8G1hvHc=";
  };

  outputs = [
    "out"
    "dev"
  ];

  postPatch = ''
    # fix libdir=''${exec_prefix}/@CMAKE_INSTALL_LIBDIR@
    sed -i 's,libdir=''${\(exec_\)\?prefix}/,libdir=,' lib3mf.pc.in

    # replace bundled binaries
    rm -r AutomaticComponentToolkit
    ln -s ${automaticcomponenttoolkit}/bin AutomaticComponentToolkit

    # unvendor Libraries
    rm -r Libraries/{fast_float,googletest,libressl,libzip,zlib}

    cat <<"EOF" >> Tests/CPP_Bindings/CMakeLists.txt
    find_package(GTest REQUIRED)
    target_link_libraries(''${TESTNAME} PRIVATE GTest::gtest)
    EOF

    mkdir Libraries/fast_float
    ln -s ${lib.getInclude fast-float}/include/ Libraries/fast_float/Include

    # functions are no longer in openssl, remove them from test cleanup function
    substituteInPlace Tests/CPP_Bindings/Source/UnitTest_EncryptionUtils.cpp \
      --replace-fail "RAND_cleanup();" "" \
      --replace-fail "EVP_cleanup();" "" \
      --replace-fail "CRYPTO_cleanup_all_ex_data();" ""

    # Fix CMake export
    # ref https://github.com/3MFConsortium/lib3mf/pull/434
    substituteInPlace cmake/lib3mfConfig.cmake \
      --replace-fail "$""{LIB3MF_ROOT_DIR}/include" "$""{LIB3MF_ROOT_DIR}/include/lib3mf" \
      --replace-fail "$""{LIB3MF_ROOT_DIR}/lib" "$out/lib"

    # Use absolute CMAKE_INSTALL_INCLUDEDIR
    substituteInPlace lib3mf.pc.in \
      --replace-fail "includedir=$""{prefix}/@CMAKE_INSTALL_INCLUDEDIR@" "includedir=@CMAKE_INSTALL_INCLUDEDIR@"
  '';

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
  ];

  buildInputs = [
    gtest
    openssl
    zlib
  ]
  ++ lib.optional (!stdenv.hostPlatform.isDarwin) libuuid;

  propagatedBuildInputs = [
    libzip
  ];

  cmakeFlags = [
    "-DCMAKE_INSTALL_INCLUDEDIR=${placeholder "dev"}/include/lib3mf"
    "-DUSE_INCLUDED_ZLIB=OFF"
    "-DUSE_INCLUDED_LIBZIP=OFF"
    "-DUSE_INCLUDED_GTEST=OFF"
    "-DUSE_INCLUDED_SSL=OFF"
  ];

  doCheck = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Reference implementation of the 3D Manufacturing Format file standard";
    homepage = "https://3mf.io/";
    changelog = "https://github.com/3MFConsortium/lib3mf/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ nim65s ];
    platforms = lib.platforms.all;
  };
})
