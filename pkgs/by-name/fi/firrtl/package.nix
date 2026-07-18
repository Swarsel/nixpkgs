{
  lib,
  stdenv,
  coursier,
  jre,
  makeWrapper,
  setJavaClassPath,
}:

stdenv.mkDerivation rec {
  pname = "firrtl";
  version = "1.5.3";

  nativeBuildInputs = [
    makeWrapper
    setJavaClassPath
  ];

  buildInputs = [ deps ];

  installPhase = ''
    runHook preInstall

    makeWrapper ${jre}/bin/java $out/bin/${pname} \
      --add-flags "-cp $CLASSPATH firrtl.stage.FirrtlMain"

    runHook postInstall
  '';

  doInstallCheck = true;

  installCheckPhase = ''
    $out/bin/firrtl --firrtl-source "${''
      circuit test:
        module test:
          input a: UInt<8>
          input b: UInt<8>
          output o: UInt
          o <= add(a, not(b))
    ''}" -o test.v
    cat test.v
    grep -qFe "module test" -e "endmodule" test.v
  '';

  deps = stdenv.mkDerivation {
    inherit version;
    pname = "${pname}-deps";
    nativeBuildInputs = [ coursier ];

    buildCommand = ''
      export COURSIER_CACHE=$(pwd)
      cs fetch edu.berkeley.cs:${pname}_${scalaVersion}:${version} > deps
      mkdir -p $out/share/java
      cp $(< deps) $out/share/java
    '';

    outputHash = "sha256-xy3zdJZk6Q2HbEn5tRQ9Z0AjyXEteXepoWDaATjiUUw=";
    outputHashMode = "recursive";
  };

  dontUnpack = true;
  scalaVersion = "2.13"; # pin, for determinism

  meta = {
    description = "Flexible Intermediate Representation for RTL";

    longDescription = ''
      Firrtl is an intermediate representation (IR) for digital circuits
      designed as a platform for writing circuit-level transformations.
    '';

    homepage = "https://www.chisel-lang.org/firrtl/";
    license = lib.licenses.asl20;
    maintainers = [ ];
    mainProgram = "firrtl";
  };
}
