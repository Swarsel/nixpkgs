{
  lib,
  stdenv,
  _experimental-update-script-combinators,
  black-hole-solver,
  desktop-file-utils,
  fetchzip,
  freecell-solver,
  gitUpdater,
  python3Packages,
}:

python3Packages.buildPythonApplication rec {
  pname = "pysolfc";
  version = "3.4.1";

  src = fetchzip {
    url = "mirror://sourceforge/pysolfc/PySolFC-${version}.tar.xz";
    hash = "sha256-jijrrWhj80n/XFKMFLptDZCsclIhdJHiTrX6CGjVju8=";
  };

  patches = [ ./pysolfc-datadir.patch ];
  nativeBuildInputs = [ desktop-file-utils ];

  propagatedBuildInputs = with python3Packages; [
    tkinter
    six
    random2
    configobj
    pysol-cards
    attrs
    pycotap
    # optional :
    pygame
    freecell-solver
    black-hole-solver
    pillow
  ];

  # No tests in archive
  doCheck = false;

  postInstall = ''
    mkdir $out/share/PySolFC/cardsets
    cp -r $cardsets/* $out/share/PySolFC/cardsets
    cp -r $music/data/music $out/share/PySolFC
  '';

  cardsets = stdenv.mkDerivation rec {
    pname = "pysol-cardsets";
    version = "3.1";

    src = fetchzip {
      url = "mirror://sourceforge/pysolfc/PySolFC-Cardsets-${version}.tar.bz2";
      hash = "sha256-NyCnMlMZ6d5+IiyG4cVn/zlDlArLJSs0dIqZiD7Nv4M=";
    };

    installPhase = ''
      runHook preInstall
      cp -r $src $out
      runHook postInstall
    '';
  };

  format = "setuptools";

  music = stdenv.mkDerivation rec {
    pname = "pysol-music";
    version = "4.50";

    src = fetchzip {
      url = "mirror://sourceforge/pysolfc/pysol-music-${version}.tar.xz";
      hash = "sha256-sOl5U98aIorrQHJRy34s0HHaSW8hMUE7q84FMQAj5Yg=";
    };

    installPhase = ''
      runHook preInstall
      cp -r $src $out
      runHook postInstall
    '';
  };

  passthru.updateScript = _experimental-update-script-combinators.sequence (
    # Needed in order to work around requirement that only one updater with features enabled is in sequence
    map (updater: updater.command) [
      (gitUpdater {
        rev-prefix = "pysolfc-";
        url = "https://github.com/shlomif/PySolFC.git";
      })
      (gitUpdater {
        attrPath = "pysolfc.cardsets";
        url = "https://github.com/shlomif/PySolFC-CardSets.git";
      })
      (gitUpdater {
        attrPath = "pysolfc.music";
        url = "https://github.com/shlomif/pysol-music.git";
      })
    ]
  );

  meta = {
    description = "Collection of more than 1000 solitaire card games";
    homepage = "https://pysolfc.sourceforge.io";
    license = lib.licenses.gpl3;
    maintainers = [ ];
    mainProgram = "pysol.py";
  };
}
