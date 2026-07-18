{
  stdenv,
  microhs,
  writeTextDir,
}:

stdenv.mkDerivation {
  src = writeTextDir "helloworld.hs" ''
    main :: IO ()
    main = putStrLn "Hello World"
  '';

  buildInputs = [ microhs ];

  buildPhase = ''
    runHook preBuild
    mhs helloworld.hs -oExe
    runHook postBuild
  '';

  doCheck = true;

  checkPhase = ''
    runHook preCheck
    ./Exe | grep "Hello World"
    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall
    touch $out
    runHook postInstall
  '';

  name = "microhs-hello-world";
}
