{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  fetchpatch,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "websocket++";
  version = "0.8.2";

  src = fetchFromGitHub {
    owner = "zaphoyd";
    repo = "websocketpp";
    rev = finalAttrs.version;
    sha256 = "sha256-9fIwouthv2GcmBe/UPvV7Xn9P2o0Kmn2hCI4jCh0hPM=";
  };

  patches = [
    # Fix build with cmake4
    (fetchpatch {
      hash = "sha256-bFCHwtRuCFz9vr4trmmBLziPSlEx6SNjsTcBv9zV8go=";
      url = "https://github.com/zaphoyd/websocketpp/commit/deb0a334471362608958ce59a6b0bcd3e5b73c24.patch?full_index=1";
    })
    # Fix build with boost187/newer asio
    # https://github.com/zaphoyd/websocketpp/pull/1164
    ./websocketpp-0.8.2-boost-1.87-compat.patch
  ];

  nativeBuildInputs = [ cmake ];

  meta = {
    description = "C++/Boost Asio based websocket client/server library";
    homepage = "https://www.zaphoyd.com/websocketpp/";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ revol-xut ];
    platforms = lib.platforms.unix;
  };
})
