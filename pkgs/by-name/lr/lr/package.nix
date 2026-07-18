{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "lr";
  version = "2.0.1";

  src = fetchFromGitHub {
    owner = "leahneukirchen";
    repo = "lr";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-zpHThIB1FS45RriE214SM9ZQJ1HyuBkBi/+PTeJjEFc=";
  };

  makeFlags = [ "PREFIX=$(out)" ];

  meta = {
    description = "List files recursively";
    homepage = "https://github.com/leahneukirchen/lr";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ vikanezrimaya ];
    platforms = lib.platforms.all;
    mainProgram = "lr";
  };
})
