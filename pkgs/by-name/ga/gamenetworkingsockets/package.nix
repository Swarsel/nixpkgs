{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  go,
  ninja,
  openssl,
  protobuf_21,
}:
let
  protobuf = protobuf_21;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "GameNetworkingSockets";
  version = "1.4.1";

  src = fetchFromGitHub {
    owner = "ValveSoftware";
    repo = "GameNetworkingSockets";
    rev = "v${finalAttrs.version}";
    sha256 = "12741wmpvy7mcvqqmjg4a7ph75rwliwgclhk4imjijqf2qkvsphd";
  };

  nativeBuildInputs = [
    cmake
    ninja
    go
  ];

  buildInputs = [ protobuf ];
  propagatedBuildInputs = [ openssl ];
  cmakeFlags = [ "-G Ninja" ];
  # tmp home for go
  preBuild = "export HOME=\"$TMPDIR\"";

  meta = {
    inherit (finalAttrs.src.meta) homepage;
    description = "GameNetworkingSockets is a basic transport layer for games";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.sternenseemann ];
    platforms = lib.platforms.unix;
  };
})
