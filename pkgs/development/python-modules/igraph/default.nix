{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cairocffi,
  cmake,
  igraph,
  matplotlib,
  pkg-config,
  plotly,
  pytestCheckHook,
  setuptools,
  texttable,
}:

buildPythonPackage rec {
  pname = "igraph";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "igraph";
    repo = "python-igraph";
    tag = version;
    hash = "sha256-Y7ZQ1yNoD8A5b6c92OGz9Unietdg1uNt/Za6nxdCSP0=";

    postFetch = ''
      # export-subst prevents reproducability
      rm $out/.git_archival.json
    '';
  };

  postPatch = ''
    rm -r vendor
  '';

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ igraph ];
  # NB: We want to use our igraph, not vendored igraph, but even with
  # pkg-config on the PATH, their custom setup.py still needs to be explicitly
  # told to do it. ~ C.
  env.IGRAPH_USE_PKG_CONFIG = true;

  nativeCheckInputs = [
    pytestCheckHook
  ]
  ++ lib.concatAttrValues optional-dependencies;

  build-system = [
    cmake
    setuptools
  ];

  dependencies = [ texttable ];

  disabledTests = [
    "testAuthorityScore"
    "test_labels"
  ];

  dontUseCmakeConfigure = true;

  optional-dependencies = {
    cairo = [ cairocffi ];
    matplotlib = [ matplotlib ];
    plotly = [ plotly ];
    plotting = [ cairocffi ];
  };

  pyproject = true;
  pythonImportsCheck = [ "igraph" ];

  meta = {
    description = "High performance graph data structures and algorithms";
    homepage = "https://igraph.org/python/";
    changelog = "https://github.com/igraph/python-igraph/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.gpl2Plus;

    maintainers = with lib.maintainers; [
      MostAwesomeDude
      dotlambda
    ];

    mainProgram = "igraph";
  };
}
