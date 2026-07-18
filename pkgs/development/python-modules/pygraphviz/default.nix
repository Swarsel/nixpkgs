{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  coreutils,
  graphviz,
  pkg-config,
  pytest,
  replaceVars,
  setuptools,
  swig,
}:

let
  # TODO: remove once #540793 makes it to master
  graphviz' = graphviz.override { withQuartz = stdenv.hostPlatform.isDarwin; };
in
buildPythonPackage (finalAttrs: {
  pname = "pygraphviz";
  version = "2.0";

  src = fetchFromGitHub {
    owner = "pygraphviz";
    repo = "pygraphviz";
    tag = "pygraphviz-${finalAttrs.version}";
    hash = "sha256-AxiaKEmVjofAi6LV1ozOPERqZyOhmBWMLV3GYlhSuNo=";
  };

  patches = [
    # pygraphviz depends on graphviz executables and wc being in PATH
    (replaceVars ./path.patch {
      path = lib.makeBinPath [
        graphviz'
        coreutils
      ];
    })
  ];

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail ', "swig>4.1.0"' ""
  '';

  nativeBuildInputs = [
    graphviz' # for dot
    pkg-config
    swig
  ];

  buildInputs = [ graphviz' ];
  env.GRAPHVIZ_PREFIX = graphviz';
  nativeCheckInputs = [ pytest ];

  checkPhase = ''
    runHook preCheck
    pytest --pyargs pygraphviz
    runHook postCheck
  '';

  build-system = [
    setuptools
  ];

  pyproject = true;
  pythonImportsCheck = [ "pygraphviz" ];

  meta = {
    description = "Python interface to Graphviz graph drawing package";
    homepage = "https://github.com/pygraphviz/pygraphviz";
    changelog = "https://github.com/pygraphviz/pygraphviz/releases/tag/pygraphviz-${finalAttrs.version}";
    license = lib.licenses.bsd3;

    maintainers = with lib.maintainers; [
      matthiasbeyer
      dotlambda
    ];
  };
})
