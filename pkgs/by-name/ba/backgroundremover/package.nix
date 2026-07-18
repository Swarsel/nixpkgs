{
  lib,
  fetchurl,
  fetchFromGitHub,
  gitUpdater,
  imagemagick,
  python3,
  runCommand,
}:

let
  p = python3.pkgs;
  self = p.buildPythonApplication rec {
    pname = "backgroundremover";
    version = "0.4.4";

    src = fetchFromGitHub {
      owner = "nadermx";
      repo = "backgroundremover";
      tag = "v${version}";
      hash = "sha256-S6irFkNw+5HHr3ziMRxaeg3QoXWe1qqf10CGTTHKpb4=";
    };

    postPatch = ''
      rm -rf *dist
      substituteInPlace backgroundremover/bg.py backgroundremover/u2net/detect.py \
        --replace-fail 'os.path.expanduser(os.path.join("~", ".u2net", model_name + ".pth"))' "os.path.join(\"$models\", model_name + \".pth\")"
    '';

    doCheck = false; # no tests

    build-system = [
      p.setuptools
    ];

    dependencies = [
      p.certifi
      p.charset-normalizer
      p.ffmpeg-python
      p.filelock
      p.filetype
      p.flask
      p.hsh
      p.idna
      p.more-itertools
      p.moviepy
      p.numpy
      p.pillow
      p.pillow-heif
      p.pymatting
      p.pysocks
      p.requests
      p.scikit-image
      p.scipy
      p.six
      p.torch
      p.torchvision
      p.tqdm
      p.urllib3
      p.waitress
    ];

    models = runCommand "background-remover-models" { } ''
      mkdir $out
      cat ${src}/models/u2a{a,b,c,d} > $out/u2net.pth
      cat ${src}/models/u2ha{a,b,c,d} > $out/u2net_human_seg.pth
      cp ${src}/models/u2netp.pth $out
    '';

    pyproject = true;
    pythonImportsCheck = [ "backgroundremover" ];

    pythonRelaxDeps = [
      "pillow"
      "torchvision"
      "moviepy"
    ];

    passthru = {
      inherit models;

      tests = {
        image =
          let
            # random no copyright car image from the internet
            demoImage = fetchurl {
              hash = "sha256-Kvd06eZdibgDbabVVe0+cNTeS1rDnMXIZZpPlHIlfBo=";
              url = "https://pics.craiyon.com/2023-07-16/38653769ac3b4e068181cb5ab1e542a1.webp";
            };
          in
          runCommand "backgroundremover-image-test.png"
            {
              buildInputs = [
                self
                imagemagick
              ];
            }
            ''
              convert ${demoImage} input.png
              export NUMBA_CACHE_DIR=$(mktemp -d)
              backgroundremover -i input.png -o $out
            '';
      };

      updateScript = gitUpdater { rev-prefix = "v"; };
    };

    meta = {
      description = "Command line tool to remove background from image and video, made by nadermx to power";
      homepage = "https://BackgroundRemoverAI.com";
      license = lib.licenses.mit;
      maintainers = [ ];
      mainProgram = "backgroundremover";
      downloadPage = "https://github.com/nadermx/backgroundremover/releases";
    };
  };
in
self
