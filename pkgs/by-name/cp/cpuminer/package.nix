{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  curl,
  fetchpatch,
  jansson,
  perl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cpuminer";
  version = "2.5.1";

  src = fetchFromGitHub {
    owner = "pooler";
    repo = "cpuminer";
    rev = "v${finalAttrs.version}";
    sha256 = "0f44i0z8rid20c2hiyp92xq0q0mjj537r05sa6vdbc0nl0a5q40i";
  };

  patches = [
    (fetchpatch {
      hash = "sha256-lGAcwDcXgcJBFhasSEdQIEIY7pp6x/PEXHBsVwAOqhc=";
      name = "fix-build-on-aarch64.patch";
      url = "https://github.com/pooler/cpuminer/commit/5f02105940edb61144c09a7eb960bba04a10d5b7.patch";
    })
  ];

  postPatch = if stdenv.cc.isClang then "${perl}/bin/perl ./nomacro.pl" else null;
  nativeBuildInputs = [ autoreconfHook ];

  buildInputs = [
    curl
    jansson
  ];

  configureFlags = [ "CFLAGS=-O3" ];

  meta = {
    description = "CPU miner for Litecoin and Bitcoin";
    homepage = "https://github.com/pooler/cpuminer";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ pSub ];
    platforms = lib.platforms.all;
    mainProgram = "minerd";
  };
})
