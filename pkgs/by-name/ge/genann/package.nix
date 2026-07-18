{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "genann";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "codeplea";
    repo = "genann";
    rev = "v${finalAttrs.version}";
    sha256 = "0z45ndpd4a64i6jayr4yxfcr5h87bsmhm7lfgnbp35pnfywiclmq";
  };

  doCheck = true;

  # Nix doesn't seem to recognize this by default.
  checkPhase = ''
    make check
  '';

  installPhase = ''
    mkdir -p $out/include
    cp ./genann.{h,c} $out/include
  '';

  dontBuild = true;

  meta = {
    description = "Simple neural network library in ANSI C";
    homepage = "https://github.com/codeplea/genann";
    license = lib.licenses.zlib;
    maintainers = [ ];
    platforms = lib.platforms.all;
  };
})
