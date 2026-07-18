{
  clangStdenv,
  objfw,
  writeTextDir,
}:

clangStdenv.mkDerivation {
  src = writeTextDir "helloworld.m" ''
    #import <ObjFW/ObjFW.h>
    int main() {
        OFLog(@"Hello world from objc");
        return 0;
    }
  '';

  buildInputs = [ objfw ];

  buildPhase = ''
    runHook preBuild
    clang -o testbinary \
            -x objective-c -Xclang \
            -fobjc-runtime=objfw \
            -funwind-tables \
            -fconstant-string-class=OFConstantString \
            -Xclang -fno-constant-cfstrings \
            helloworld.m \
            -lobjfw -lobjfwrt
    runHook postBuild
  '';

  doCheck = true;

  checkPhase = ''
    runHook preCheck
    ./testbinary
    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall
    touch $out
    runHook postInstall
  '';

  name = "ObjFW test";
}
