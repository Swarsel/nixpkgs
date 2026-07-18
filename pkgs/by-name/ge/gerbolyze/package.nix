{
  lib,
  stdenv,
  fetchFromGitHub,
  gitUpdater,
  python3Packages,
  resvg,
}:

let
  version = "3.2.0";
  src = fetchFromGitHub {
    owner = "jaseg";
    repo = "gerbolyze";
    tag = "v${version}";
    hash = "sha256-T3e0qoVD98u2lgCmQvof2SOqV8WkBkZrhnccURlJqsA=";
    fetchSubmodules = true;
  };

  svg-flatten = stdenv.mkDerivation rec {
    inherit version src;
    pname = "svg-flatten";

    preInstall = ''
      mkdir -p $out/bin
    '';

    installFlags = [ "PREFIX=$(out)" ];
    sourceRoot = "${src.name}/svg-flatten";

    meta = {
      description = "SVG-flatten SVG downconverter";
      homepage = "https://github.com/jaseg/gerbolyze";
      license = with lib.licenses; [ agpl3Plus ];
      maintainers = with lib.maintainers; [ wulfsta ];
      platforms = lib.platforms.linux;
      mainProgram = "svg-flatten";
    };
  };
in
python3Packages.buildPythonApplication {
  inherit version src;
  pname = "gerbolyze";

  nativeCheckInputs = [
    python3Packages.pytestCheckHook
    resvg
    svg-flatten
  ];

  preCheck = ''
    substituteInPlace tests/test_integration.py \
      --replace-fail "'gerbolyze'" "'${placeholder "out"}/bin/gerbolyze'"
  '';

  build-system = with python3Packages; [ uv-build ];

  dependencies = with python3Packages; [
    beautifulsoup4
    click
    numpy
    python-slugify
    lxml
    gerbonara
    resvg
  ];

  makeWrapperArgs = [
    "--prefix PATH : ${
      lib.makeBinPath [
        resvg
        svg-flatten
      ]
    }"
  ];

  pyproject = true;
  pythonImportsCheck = [ "gerbolyze" ];

  pythonRemoveDeps = [
    # we already provide svg-flatten through a binary on the PATH
    "resvg-wasi"
    "svg-flatten-wasi"
  ];

  passthru.updateScript = gitUpdater {
    rev-prefix = "v";
  };

  meta = {
    description = "Directly render SVG overlays into Gerber and Excellon files";
    homepage = "https://github.com/jaseg/gerbolyze";
    license = with lib.licenses; [ agpl3Plus ];
    maintainers = with lib.maintainers; [ wulfsta ];
    platforms = lib.platforms.linux;
    mainProgram = "gerbolyze";
  };
}
