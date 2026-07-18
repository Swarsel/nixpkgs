{
  lib,
  fetchFromGitHub,
  bashNonInteractive,
  coreutils,
  file,
  highlight,
  imagemagick,
  less,
  nix-update-script,
  python3Packages,
  w3m,
  imagePreviewSupport ? true,
  improvedEncodingDetection ? true,
  neoVimSupport ? true,
  rightToLeftTextSupport ? false,
  sixelPreviewSupport ? true,
}:

python3Packages.buildPythonApplication {
  pname = "ranger";
  version = "1.9.4-unstable-2026-04-26";

  src = fetchFromGitHub {
    owner = "ranger";
    repo = "ranger";
    rev = "51e19b8c7f30c241bb7266deb86e05c5984d6ea9";
    hash = "sha256-qWI/7F2zOUm7QuH4RtfFOXlB1OZ6NrGfWLt5FlW+gqA=";
  };

  postPatch = ''
    substituteInPlace ranger/__init__.py \
      --replace "DEFAULT_PAGER = 'less'" "DEFAULT_PAGER = '${lib.getBin less}/bin/less'"

    # give file previews out of the box
    substituteInPlace ranger/config/rc.conf \
      --replace /usr/share $out/share \
      --replace "#set preview_script ~/.config/ranger/scope.sh" "set preview_script $out/share/doc/ranger/config/scope.sh"
  ''
  + lib.optionalString (highlight != null) ''
    sed -i -e 's|^\s*highlight\b|${highlight}/bin/highlight|' \
      ranger/data/scope.sh
  ''
  + lib.optionalString imagePreviewSupport ''
    substituteInPlace ranger/ext/img_display.py \
      --replace /usr/lib/w3m ${w3m}/libexec/w3m

    # give image previews out of the box when building with w3m
    substituteInPlace ranger/config/rc.conf \
      --replace "set preview_images false" "set preview_images true"
  '';

  nativeCheckInputs = with python3Packages; [
    pytestCheckHook
    astroid
    pylint
  ];

  build-system = with python3Packages; [
    setuptools
  ];

  dependencies =
    [ ]
    ++ lib.optionals imagePreviewSupport [ python3Packages.pillow ]
    ++ lib.optionals neoVimSupport [ python3Packages.pynvim ]
    ++ lib.optionals improvedEncodingDetection [ python3Packages.chardet ]
    ++ lib.optionals rightToLeftTextSupport [ python3Packages.python-bidi ];

  makeWrapperArgs = [
    "--prefix"
    "PATH"
    ":"
    (lib.makeBinPath (
      [
        file
        coreutils
        bashNonInteractive
      ]
      ++ lib.optionals sixelPreviewSupport [ imagemagick ]
    ))
  ];

  pyproject = true;

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--version=branch" ];
  };

  meta = {
    description = "File manager with minimalistic curses interface";
    homepage = "https://ranger.fm/";
    license = lib.licenses.gpl3Only;

    maintainers = with lib.maintainers; [
      toonn
    ];

    platforms = lib.platforms.unix;
    mainProgram = "ranger";
  };
}
