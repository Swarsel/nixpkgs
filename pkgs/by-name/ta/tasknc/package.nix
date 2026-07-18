{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch,
  makeWrapper,
  ncurses5,
  perl,
  taskwarrior2,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "tasknc";
  version = "2020-12-17";

  src = fetchFromGitHub {
    owner = "lharding";
    repo = "tasknc";
    rev = "a182661fbcc097a933d5e8cce3922eb1734a563e";
    sha256 = "0jrv2k1yizfdjndbl06lmy2bb62ky2rjdk308967j31c5kqqnw56";
  };

  # Pull pending upstream inclusion for ncurses-6.3:
  #  https://github.com/lharding/tasknc/pull/57
  patches = [
    (fetchpatch {
      name = "ncurses-6.3.patch";
      sha256 = "18a90zj85sw2zfnfcv055nvi0lx3h8lcgsyabdfk94ksn78pygrv";
      url = "https://github.com/lharding/tasknc/commit/f74ea0641e9bf287acf22fac9f6eeea571b01800.patch";
    })
  ];

  nativeBuildInputs = [
    makeWrapper
    perl # For generating the man pages with pod2man
  ];

  buildInputs = [ ncurses5 ];
  buildFlags = [ "VERSION=${finalAttrs.version}" ];

  installPhase = ''
    mkdir -p $out/bin/
    mkdir -p $out/share/man/man1
    mkdir -p $out/share/tasknc

    DESTDIR=$out PREFIX= MANPREFIX=/share/man make install

    wrapProgram $out/bin/tasknc --prefix PATH : ${taskwarrior2}/bin
  '';

  hardeningDisable = [ "format" ];

  meta = {
    description = "Ncurses wrapper around taskwarrior";
    homepage = "https://github.com/lharding/tasknc";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ matthiasbeyer ];
    platforms = lib.platforms.linux; # Cannot test others
    mainProgram = "tasknc";
  };
})
