{
  lib,
  stdenv,
  fetchurl,
  jre8,
  makeDesktopItem,
  unzip,
}:

let
  desktopItem = makeDesktopItem {
    categories = [
      "Graphics"
      "Education"
      "Science"
      "Chemistry"
    ];

    desktopName = "JMol";
    exec = "jmol";
    genericName = "Molecular Modeler";

    mimeTypes = [
      "chemical/x-pdb"
      "chemical/x-mdl-molfile"
      "chemical/x-mol2"
      "chemical/seq-aa-fasta"
      "chemical/seq-na-fasta"
      "chemical/x-xyz"
      "chemical/x-mdl-sdf"
    ];

    name = "jmol";
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "jmol";
  version = "16.4.11";

  src =
    let
      baseVersion = "${lib.versions.major finalAttrs.version}.${lib.versions.minor finalAttrs.version}";
    in
    fetchurl {
      url = "mirror://sourceforge/jmol/Jmol/Version%20${baseVersion}/Jmol%20${finalAttrs.version}/Jmol-${finalAttrs.version}-binary.tar.gz";
      hash = "sha256-kDt6XF5axy9DhygLZcImV37plkq/xDqi2aL2wKV9wh4=";
    };

  installPhase = ''
    mkdir -p "$out/share/jmol" "$out/bin"

    ${unzip}/bin/unzip jsmol.zip -d "$out/share/"

    cp *.jar jmol.sh "$out/share/jmol"
    cp -r ${desktopItem}/share/applications $out/share
    cp jmol $out/bin
  '';

  enableParallelBuilding = true;

  patchPhase = ''
    sed -i -e "4s:.*:command=${jre8}/bin/java:" -e "10s:.*:jarpath=$out/share/jmol/Jmol.jar:" -e "11,21d" jmol
  '';

  meta = {
    description = "Java 3D viewer for chemical structures";
    homepage = "https://sourceforge.net/projects/jmol";
    license = lib.licenses.lgpl2;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    platforms = lib.platforms.all;
    mainProgram = "jmol";
    teams = [ lib.teams.sage ];
  };
})
