{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "djenrandom";
  version = "1.0";

  src = fetchFromGitHub {
    owner = "dj-on-github";
    repo = "djenrandom";
    rev = "${finalAttrs.version}";
    hash = "sha256-r5UT8z8vvFZDffsl6CqBXuvBaZ/sl1WLxJi26CxkpAw=";
  };

  makeFlags = [ "CC=${stdenv.cc.targetPrefix}cc" ];

  preBuild = ''
    sed -i s/gcc/${stdenv.cc.targetPrefix}gcc/g Makefile
  ''
  + lib.optionalString (!stdenv.hostPlatform.isx86_64) ''
    sed -i s/-m64//g Makefile
  '';

  installPhase = ''
    runHook preInstall
    install -D djenrandom $out/bin/djenrandom
    runHook postInstall
  '';

  meta = {
    description = ''
      C program to generate random data using several random models,
      with parameterized non uniformities and flexible output formats
    '';

    homepage = "http://www.deadhat.com/";
    license = lib.licenses.gpl2Only;

    maintainers = with lib.maintainers; [
      orichter
      thillux
    ];

    # djenrandom uses x86 specific instructions, therefore we can only compile for the x86 architecture
    platforms = lib.platforms.x86;
    mainProgram = "djenrandom";
  };
})
