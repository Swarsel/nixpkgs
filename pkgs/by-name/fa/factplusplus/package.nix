{
  lib,
  stdenv,
  fetchFromBitbucket,
  jdk,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "factplusplus";
  version = "1.6.5";

  src = fetchFromBitbucket {
    owner = "dtsarkov";
    repo = "factplusplus";
    rev = "Release-${finalAttrs.version}";
    sha256 = "wzK1QJsNN0Q73NM+vjaE/vLuGf8J1Zu5ZPAkZNiKnME=";
  };

  buildInputs = [ jdk ];

  installPhase = ''
    runHook preInstall

    install -Dm755 FaCT++.{C,JNI,KE,Kernel}/obj/*.{so,o} -t $out/lib/
    install -Dm755 FaCT++/obj/FaCT++ -t $out/bin

    runHook postInstall
  '';

  configurePhase = ''
    runHook preConfigure

    sed -i 's/OS = MACOSX/OS = LINUX/g' Makefile.include
    printf '%s\n%s\n' '#include <iostream>' "$(cat Kernel/AtomicDecomposer.cpp)" > Kernel/AtomicDecomposer.cpp

    runHook postConfigure
  '';

  meta = {
    description = "Tableaux-based reasoner for expressive Description Logics (DL)";
    homepage = "http://owl.cs.manchester.ac.uk/tools/fact/";
    license = lib.licenses.gpl2Plus;
    maintainers = [ lib.maintainers.mgttlinger ];
    platforms = with lib.platforms; linux ++ darwin ++ windows;
    mainProgram = "FaCT++";
    broken = !stdenv.hostPlatform.isLinux;
  };
})
