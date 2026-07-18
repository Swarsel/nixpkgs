{
  lib,
  stdenv,
  fetchFromGitHub,
  groff,
  makeWrapper,
  ncurses,
  runtimeShell,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "jove";
  version = "4.17.5.5";

  src = fetchFromGitHub {
    owner = "jonmacs";
    repo = "jove";
    rev = finalAttrs.version;
    hash = "sha256-y0zNrUXHXqBa6xNxRiZSUOSrFT2cDmdpMsCRHJXpUac=";
  };

  postPatch = ''
    patchShebangs testbuild.sh testmailer.sh teachjove jmake.sh
  '';

  nativeBuildInputs = [ makeWrapper ];

  buildInputs = [
    groff
    ncurses
  ];

  preBuild = ''
    makeFlagsArray+=(SYSDEFS="-DSYSVR4 -D_XOPEN_SOURCE=500" \
      OPTFLAGS="-O -Wno-error=incompatible-pointer-types" \
      JTMPDIR=$TMPDIR
      TERMCAPLIB=-lncurses \
      SHELL=${runtimeShell} \
      DFLTSHELL=${runtimeShell} \
      JOVEHOME=${placeholder "out"})
  '';

  postInstall = ''
    wrapProgram $out/bin/teachjove \
      --prefix PATH ":" "$out/bin"
  '';

  dontConfigure = true;

  meta = {
    description = "Jonathan's Own Version of Emacs";
    homepage = "https://github.com/jonmacs/jove";
    changelog = "https://github.com/jonmacs/jove/releases/tag/${finalAttrs.version}";
    license = lib.licenses.bsd2;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    # never built on Hydra: https://hydra.nixos.org/job/nixpkgs/trunk/jove.x86_64-darwin
    broken = stdenv.hostPlatform.isDarwin;
  };
})
