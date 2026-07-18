{
  lib,
  fetchFromGitHub,
  fetchpatch,
  gettext,
  python3,
}:
let
  version = "3.2.2";

  dependencies = with python3.pkgs; [
    pyembroidery
    inkex
    wxpython
    networkx
    platformdirs
    shapely
    lxml
    appdirs
    numpy
    jinja2
    requests
    colormath2
    flask
    fonttools
    trimesh
    scipy
    diskcache
    flask-cors
  ];
  pyEnv = python3.withPackages (_: dependencies);
in
python3.pkgs.buildPythonApplication {
  inherit version;
  inherit dependencies;
  pname = "inkstitch";

  src = fetchFromGitHub {
    owner = "inkstitch";
    repo = "inkstitch";
    tag = "v${version}";
    hash = "sha256-6EVfjmTXEYgZta01amK8E6t5h2JBPfGGNnqfBG8LQfo=";
  };

  patches = [
    ./0001-force-frozen-true.patch
    ./0002-plugin-invocation-use-python-script-as-entrypoint.patch
    ./0003-lazy-load-module-to-access-global_settings.patch
    ./0004-enable-force-insertion-of-python-path.patch

    # Fix compatibility with inkex 1.4
    # https://github.com/inkstitch/inkstitch/pull/3825
    (fetchpatch {
      hash = "sha256-nAs1rAr3lvN5Qwhj0I+7puM3R2X1NoHpB0ltvlwHDXA=";
      url = "https://github.com/inkstitch/inkstitch/commit/454b5ee1a00e9d4b96f5f057a8611da68a6cc796.patch";
    })
  ];

  postPatch = ''
    # Add shebang with python dependencies
    substituteInPlace lib/inx/utils.py --replace-fail ' interpreter="python"' ""
    sed -i -e '1i#!${pyEnv.interpreter}' inkstitch.py
    chmod a+x inkstitch.py
  '';

  nativeBuildInputs = [
    gettext
    pyEnv
  ];

  makeFlags = [ "manual" ];

  env = {
    BUILD = "nixpkgs";
    # to overwrite version string
    GITHUB_REF = version;
  };

  doCheck = false;

  nativeCheckInputs = with python3.pkgs; [
    pytestCheckHook
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/inkscape/extensions
    cp -a . $out/share/inkscape/extensions/inkstitch

    runHook postInstall
  '';

  postInstall = ''
    export SITE_PACKAGES=$(find "${pyEnv}" -type d -name 'site-packages')
    wrapProgram $out/share/inkscape/extensions/inkstitch/inkstitch.py \
      --set PYTHON_INKEX_PATH "$SITE_PACKAGES"
  '';

  pyproject = false; # Uses a Makefile (yikes)

  meta = {
    description = "Inkscape extension for machine embroidery design";
    homepage = "https://inkstitch.org/";
    license = with lib.licenses; [ gpl3Plus ];

    maintainers = with lib.maintainers; [
      tropf
      pluiedev
    ];
  };
}
