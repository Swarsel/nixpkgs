{
  lib,
  fetchurl,
  fetchFromGitHub,
  python3,
  unzip,
  enableDefaultMusicPack ? true,
}:

let
  pname = "endgame-singularity";
  version = "1.1";

  main_src = fetchFromGitHub {
    hash = "sha256-wYXuhlGp7gisgN2iRXKTpe0Om2AA8u0eBwKHHIYuqbk=";
    owner = "singularity";
    repo = "singularity";
    tag = "v${version}";
  };

  music_src = fetchurl {
    sha256 = "0vf2qaf66jh56728pq1zbnw50yckjz6pf6c6qw6dl7vk60kkqnpb";
    url = "http://www.emhsoft.com/singularity/endgame-singularity-music-007.zip";
  };
in

python3.pkgs.buildPythonApplication {
  inherit pname version;

  postPatch = ''
    substituteInPlace setup.py \
      --replace-fail "pygame>=2.5.2" "pygame-ce"
  '';

  nativeBuildInputs = [ unzip ]; # The music is zipped

  # Add the music
  postInstall = lib.optionalString enableDefaultMusicPack ''
    cp -R "../endgame-singularity-music-007" \
          "$(echo $out/lib/python*/site-packages/singularity)/music"
          # ↑ we cannot glob on [...]/music, it doesn't exist yet
  '';

  build-system = with python3.pkgs; [
    setuptools
  ];

  dependencies = with python3.pkgs; [
    pygame-ce
    numpy
    polib
  ];

  pyproject = true;
  sourceRoot = main_src.name;
  srcs = [ main_src ] ++ lib.optional enableDefaultMusicPack music_src;

  meta = {
    description = "Simulation game about strong AI";

    longDescription = ''
      A simulation of a true AI. Go from computer to computer, pursued by the
      entire world. Keep hidden, and you might have a chance
    '';

    homepage = "http://www.emhsoft.com/singularity/";

    # License details are in LICENSE.txt
    license = with lib.licenses; [
      gpl2Plus # most of the code, some translations
      mit # recursive_fix_pickle, polib
      cc-by-sa-30 # data and artwork, some translations
      free # earth images from NASA, some fonts
      cc0 # cick0.wav
    ];

    maintainers = with lib.maintainers; [ fgaz ];
    mainProgram = "singularity";
  };
}
