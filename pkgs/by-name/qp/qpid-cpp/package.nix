{
  lib,
  stdenv,
  fetchurl,
  boost183,
  cmake,
  fetchpatch,
  libuuid,
  python3,
  ruby,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "qpid-cpp";
  version = "1.39.0";

  src = fetchurl {
    url = "mirror://apache/qpid/cpp/${finalAttrs.version}/qpid-cpp-${finalAttrs.version}.tar.gz";
    hash = "sha256-eYDQ6iHVV1WUFFdyHGnbqGIjE9CrhHzh0jP7amjoDSE=";
  };

  patches = [
    (fetchpatch {
      hash = "sha256-pV6xx8Nrys/ZxIO0Z/fARH0ELqcSdTXLPsVXYUd3f70=";
      name = "python3-managementgen";
      url = "https://github.com/apache/qpid-cpp/commit/0e558866e90ef3d5becbd2f6d5630a6a6dc43a5d.patch";
    })
  ];

  # the subdir managementgen wants to install python stuff in ${python} and
  # the installation tries to create some folders in /var
  postPatch = ''
    sed -i '/managementgen/d' CMakeLists.txt
    sed -i '/ENV/d' src/CMakeLists.txt
    sed -i '/management/d' CMakeLists.txt

    substituteInPlace {./,examples/}CMakeLists.txt \
      --replace-fail "cmake_minimum_required(VERSION 2.8.7 FATAL_ERROR)" "cmake_minimum_required(VERSION 3.10)"
    substituteInPlace CMakeLists.txt \
      --replace-fail "cmake_policy(SET CMP0022 OLD)" ""
  '';

  nativeBuildInputs = [
    cmake
    python3
  ];

  buildInputs = [
    boost183
    libuuid
    ruby
  ];

  env.NIX_CFLAGS_COMPILE = toString (
    [
      "-Wno-error=maybe-uninitialized"
    ]
    ++ lib.optionals stdenv.cc.isGNU [
      "-Wno-error=deprecated-copy"
    ]
  );

  meta = {
    description = "AMQP message broker and a C++ messaging API";
    homepage = "https://qpid.apache.org";
    license = lib.licenses.asl20;
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };
})
