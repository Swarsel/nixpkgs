{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch,
  glib,
  hexdump,
  pkg-config,
  scowl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "halfempty";
  version = "0.40";

  src = fetchFromGitHub {
    owner = "googleprojectzero";
    repo = "halfempty";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-YGq6fneAMo2jCpLPrjzRJ0eeOsStKaK5L+lwQfqcfpY=";
  };

  patches = [
    (fetchpatch {
      name = "fix-bash-specific-syntax.patch";
      sha256 = "sha256:0hgdci0wwi5wyw8i57w0545cxjmsmswm1y6g4vhykap0y40zizav";
      url = "https://github.com/googleprojectzero/halfempty/commit/ad15964d0fcaba12e5aca65c8935ebe3f37d7ea3.patch";
    })
  ];

  postPatch = ''
    substituteInPlace test/Makefile \
      --replace '/usr/share/dict/words' '${scowl}/share/dict/words.txt'
  '';

  nativeBuildInputs = [
    pkg-config
    hexdump
  ];

  buildInputs = [ glib ];
  makeFlags = [ "CC=${stdenv.cc.targetPrefix}cc" ];
  doCheck = true;

  installPhase = ''
    install -vDt $out/bin halfempty
  '';

  checkTarget = "test";
  enableParallelBuilding = true;

  meta = {
    description = "Fast, parallel test case minimization tool";
    homepage = "https://github.com/googleprojectzero/halfempty/";
    license = with lib.licenses; [ asl20 ];
    maintainers = with lib.maintainers; [ fpletz ];
    platforms = lib.platforms.unix;
    mainProgram = "halfempty";
  };
})
