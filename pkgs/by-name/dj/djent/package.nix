{
  lib,
  stdenv,
  fetchFromGitHub,
  mpfr,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "djent";
  version = "1.0";

  src = fetchFromGitHub {
    owner = "dj-on-github";
    repo = "djent";
    rev = "${finalAttrs.version}";
    hash = "sha256-inMh7l/6LlrVnIin+L+fj+4Lchk0Xvt09ngVrCuvphE=";
  };

  buildInputs = [ mpfr ];
  makeFlags = [ "CC=${stdenv.cc.targetPrefix}cc" ];

  preBuild = ''
    sed -i s/gcc/${stdenv.cc.targetPrefix}gcc/g Makefile
  ''
  + lib.optionalString (!stdenv.hostPlatform.isx86_64) ''
    sed -i s/-m64//g Makefile
  '';

  installPhase = ''
    runHook preInstall
    install -D djent $out/bin/djent
    runHook postInstall
  '';

  enableParallelBuilding = true;

  meta = {
    description = ''
      Reimplementation of the Fourmilab/John Walker random number test program
      ent with several improvements
    '';

    homepage = "http://www.deadhat.com/";
    license = lib.licenses.gpl2Only;

    maintainers = with lib.maintainers; [
      orichter
      thillux
    ];

    platforms = lib.platforms.all;
    mainProgram = "djent";
  };
})
