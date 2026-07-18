{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  igraph,
  matplotlib,
  networkx,
  numpy,
  pandas,
  pylint,
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "iplotx";
  version = "1.7.1";

  src = fetchFromGitHub {
    owner = "fabilab";
    repo = "iplotx";
    tag = finalAttrs.version;
    hash = "sha256-vLYjTYdt3ctaUwnzV73vNWu2uKpER92SH8uqeLR/G7M=";
  };

  postPatch = ''
    # silence matplotlib warning
    export MPLCONFIGDIR=$(mktemp -d)
  '';

  nativeCheckInputs = [
    pytestCheckHook
  ]
  ++ lib.concatAttrValues finalAttrs.passthru.optional-dependencies;

  build-system = [ hatchling ];

  dependencies = [
    matplotlib
    numpy
    pandas
    pylint
  ];

  disabledTests = [
    # These tests result in an ImageComparisonFailure
    "test_complex"
    "test_complex_rotatelabels"
    "test_curved_waypoints"
    "test_directed_graph"
    "test_display_shortest_path"
    "test_labels"
    "test_labels_and_colors"
    "test_vertex_labels"
  ];

  optional-dependencies = {
    igraph = [ igraph ];
    networkx = [ networkx ];
  };

  pyproject = true;
  pythonImportsCheck = [ "iplotx" ];
  pythonRelaxDeps = [ "pylint" ];

  meta = {
    description = "Plot networkx from igraph and networkx";
    homepage = "https://iplotx.readthedocs.io/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ jboy ];
  };
})
