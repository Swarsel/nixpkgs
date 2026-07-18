{
  lib,
  stdenv,
  dos2unix,
  fetchzip,
  soundPack ? stdenv.mkDerivation {
    src = fetchzip {
      url = "https://df.zweistein.cz/soundsense/soundpack.zip";
      hash = "sha256-yjlhBLYYv/FXsk5IpiZNDG2ugDldaD5mf+Dyc6es4GM=";
    };

    installPhase = ''
      cp -r . $out
    '';

    name = "soundsense-soundpack";
  },
}:

stdenv.mkDerivation rec {
  inherit soundPack;
  pname = "soundsense";
  version = "2016-1_196";

  src = fetchzip {
    url = "https://df.zweistein.cz/soundsense/soundSense_${version}.zip";
    hash = "sha256-c+LOUxmJaZ3VqVOBYSQypiZxWyNAXOlRQVD3QZPReb4=";
  };

  nativeBuildInputs = [ dos2unix ];

  buildPhase = ''
    dos2unix soundSense.sh
    chmod +x soundSense.sh
  '';

  installPhase = ''
    mkdir $out
    cp -R . $out/soundsense
    ln -s $out/soundsense/dfhack $out/hack
    ln -s $soundPack $out/soundsense/packs
  '';

  dfVersion = "0.44.12";
  passthru = { inherit version dfVersion; };

  meta = {
    description = "Plays sound based on Dwarf Fortress game logs";
    homepage = "https://df.zweistein.cz/soundsense";
    license = lib.licenses.gpl3Only;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];

    maintainers = with lib.maintainers; [
      numinit
    ];

    platforms = lib.platforms.all;
  };
}
