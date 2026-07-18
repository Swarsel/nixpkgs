{
  lib,
  fetchurl,
  jre,
  stdenvNoCC,
}:

let
  version = "1.9.24";
  versionSnakeCase = builtins.replaceStrings [ "." ] [ "_" ] version;
in
stdenvNoCC.mkDerivation {
  inherit version;
  pname = "aspectj";

  src = fetchurl {
    url = "https://github.com/eclipse/org.aspectj/releases/download/V${versionSnakeCase}/aspectj-${version}.jar";
    hash = "sha256-p+UOtuP8hNymfvmL/SPg99YrhU7m5GDudtLISqL5TWQ=";
  };

  nativeBuildInputs = [ jre ];

  installPhase = ''
    runHook preInstall

    cat >> props <<EOF
    output.dir=$out
    context.javaPath=${jre}
    EOF

    mkdir -p $out
    java -jar $src -text props

    cat >> $out/bin/aj-runtime-env <<EOF
    #! ${stdenvNoCC.shell}

    export CLASSPATH=$CLASSPATH:.:$out/lib/aspectjrt.jar
    EOF

    chmod u+x $out/bin/aj-runtime-env

    runHook postInstall
  '';

  __structuredAttrs = true;
  dontUnpack = true;

  meta = {
    description = "Seamless aspect-oriented extension to the Java programming language";
    homepage = "https://www.eclipse.org/aspectj/";
    license = lib.licenses.epl10;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    platforms = lib.platforms.unix;
  };
}
