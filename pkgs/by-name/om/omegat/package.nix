{
  lib,
  stdenv,
  fetchurl,
  jdk,
  makeWrapper,
  unzip,
}:

stdenv.mkDerivation {
  pname = "omegat";
  version = "6.0.1";

  src = fetchurl {
    # their zip has repeated files or something, so no fetchzip
    url = "mirror://sourceforge/project/omegat/OmegaT%20-%20Standard/OmegaT%206.0.1/OmegaT_6.0.1_Without_JRE.zip";
    sha256 = "sha256-Rj50bzT8k7+GWb0p/ma+zy+PzkF7tB6iV4F4UVAImJg=";
  };

  nativeBuildInputs = [
    makeWrapper
    unzip
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp -r lib docs images plugins scripts *.txt *.html OmegaT.jar $out/

    cat > $out/bin/omegat <<EOF
    #! $SHELL -e
    CLASSPATH="$out/lib"
    exec ${jdk}/bin/java -jar -Xmx1024M $out/OmegaT.jar "\$@"
    EOF
    chmod +x $out/bin/omegat
  '';

  unpackCmd = "unzip -o $curSrc"; # tries to go interactive without -o

  meta = {
    description = "Free computer aided translation (CAT) tool for professionals";

    longDescription = ''
      OmegaT is a free and open source multiplatform Computer Assisted Translation
      tool with fuzzy matching, translation memory, keyword search, glossaries, and
      translation leveraging into updated projects.
    '';

    homepage = "http://www.omegat.org/";
    license = lib.licenses.gpl3Plus;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    maintainers = with lib.maintainers; [ t184256 ];

    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];

    mainProgram = "omegat";
  };
}
