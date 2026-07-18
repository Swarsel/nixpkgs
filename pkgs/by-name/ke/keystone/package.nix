{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  fixDarwinDylibNames,
  pkg-config,
  python3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "keystone";
  version = "0.9.2";

  src = fetchFromGitHub {
    owner = "keystone-engine";
    repo = "keystone";
    rev = finalAttrs.version;
    sha256 = "020d1l1aqb82g36l8lyfn2j8c660mm6sh1nl4haiykwgdl9xnxfa";
  };

  patches = [
    # Patches from https://github.com/keystone-engine/keystone/pull/593
    ./gcc15.patch
    ./cmake-3.10.patch
  ];

  nativeBuildInputs = [
    pkg-config
    cmake
    python3
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    # TODO: could be replaced by setting CMAKE_INSTALL_NAME_DIR?
    fixDarwinDylibNames
  ];

  cmakeFlags = [
    "-DBUILD_SHARED_LIBS=ON"
    "-DCMAKE_INSTALL_LIBDIR=lib"
  ];

  meta = {
    description = "Lightweight multi-platform, multi-architecture assembler framework";
    homepage = "https://www.keystone-engine.org";
    license = lib.licenses.gpl2Only;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "kstool";
  };
})
