{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ciao";
  version = "1.25.0-m1";

  src = fetchFromGitHub {
    owner = "ciao-lang";
    repo = "ciao";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-jsHz50+R/bs19ees3kKYalYk72ET9eSAAUY7QogI0go=";
  };

  postPatch = ''
    # hotfix https://github.com/ciao-lang/ciao/issues/122
    substituteInPlace builder/sh_src/build_car.sh \
      --replace-fail 'ln -s "$i" "$b"' 'ln -sr "$i" "$b"'
  '';

  buildPhase = ''
    ./ciao-boot.sh build
  '';

  installPhase = ''
    ./ciao-boot.sh install
  '';

  configurePhase = ''
    ./ciao-boot.sh configure --instype=global --prefix=$prefix
  '';

  meta = {
    description = "General purpose, multi-paradigm programming language in the Prolog family";
    homepage = "https://ciao-lang.org/";
    license = lib.licenses.lgpl21;
    maintainers = with lib.maintainers; [ suhr ];
    platforms = lib.platforms.unix;
    broken = stdenv.hostPlatform.isDarwin; # never built on Hydra https://hydra.nixos.org/job/nixpkgs/staging-next/ciao.x86_64-darwin
  };
})
