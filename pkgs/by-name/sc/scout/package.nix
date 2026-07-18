{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "scout";
  version = "0.15.1";

  src = fetchFromGitHub {
    owner = "liamg";
    repo = "scout";
    rev = "v${finalAttrs.version}";
    hash = "sha256-9SimePyBUXXfT4+ZtciQMaoyXpyKi9D3LTwud8QMJ6w=";
  };

  vendorHash = "sha256-reoE3WNgulREwxoeGFEN1QONZ2q1LHmQF7+iGx0SGTY=";

  meta = {
    description = "Lightweight URL fuzzer and spider: Discover a web server's undisclosed files, directories and VHOSTs";
    homepage = "https://github.com/liamg/scout";
    license = lib.licenses.unlicense;
    maintainers = with lib.maintainers; [ totoroot ];
    platforms = lib.platforms.unix;
    mainProgram = "scout";
  };
})
