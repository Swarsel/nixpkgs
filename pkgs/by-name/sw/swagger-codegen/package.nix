{
  lib,
  stdenv,
  fetchurl,
  jre,
  makeWrapper,
}:

stdenv.mkDerivation rec {
  pname = "swagger-codegen";
  version = "2.4.52";

  src = fetchurl {
    url = "mirror://maven/io/swagger/${pname}-cli/${version}/${jarfilename}";
    sha256 = "sha256-8MwqDGP6A2V2B0kGOTVpf66yOGzUCe1bFOO/l+GBrmY=";
  };

  nativeBuildInputs = [
    makeWrapper
  ];

  installPhase = ''
    install -D $src $out/share/java/${jarfilename}

    makeWrapper ${jre}/bin/java $out/bin/${pname} \
      --add-flags "-jar $out/share/java/${jarfilename}"
  '';

  dontUnpack = true;
  jarfilename = "${pname}-cli-${version}.jar";

  meta = {
    description = "Allows generation of API client libraries (SDK generation), server stubs and documentation automatically given an OpenAPI Spec";
    homepage = "https://github.com/swagger-api/swagger-codegen";
    license = lib.licenses.asl20;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    maintainers = [ lib.maintainers.jraygauthier ];
    mainProgram = "swagger-codegen";
  };
}
