{
  lib,
  stdenv,
  fetchurl,
  jre_headless,
  makeWrapper,
}:

stdenv.mkDerivation rec {
  pname = "trino-cli";
  version = "476";

  src = fetchurl {
    url = "mirror://maven/io/trino/${pname}/${version}/${jarfilename}";
    sha256 = "sha256-/k6cf7VpzWdnOvoWIpRfYwjh5ZvbglQZNSuAiHZhdXs=";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    install -D "$src" "$out/share/java/${jarfilename}"

    makeWrapper ${jre_headless}/bin/java $out/bin/trino \
      --add-flags "-jar $out/share/java/${jarfilename}"

    runHook postInstall
  '';

  dontUnpack = true;
  jarfilename = "${pname}-${version}-executable.jar";

  meta = {
    description = "Trino CLI provides a terminal-based, interactive shell for running queries";
    homepage = "https://github.com/trinodb/trino";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      regadas
      cpcloud
    ];

    mainProgram = "trino";
  };
}
