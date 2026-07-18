{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  buildPackages,
  pkg-config,
  protobuf_33,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "protobuf-c";
  version = "1.5.2";

  src = fetchFromGitHub {
    owner = "protobuf-c";
    repo = "protobuf-c";
    tag = "v${finalAttrs.version}";
    hash = "sha256-bpxk2o5rYLFkx532A3PYyhh2MwVH2Dqf3p/bnNpQV7s=";
  };

  outputs = [
    "out"
    "dev"
    "lib"
  ];

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    protobuf_33
    zlib
  ];

  env.PROTOC = lib.getExe buildPackages.protobuf_33;

  meta = {
    description = "C bindings for Google's Protocol Buffers";
    homepage = "https://github.com/protobuf-c/protobuf-c/";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ nickcao ];
    platforms = lib.platforms.all;
  };
})
