{
  lib,
  # build time
  stdenv,
  fetchFromGitHub,
  asdf,
  asdf-astropy,
  # dependencies
  astropy-iers-data,
  beautifulsoup4,
  bottleneck,
  buildPythonPackage,
  certifi,
  cython,
  dask,
  extension-helpers,
  fsspec,
  h5py,
  html5lib,
  # testing
  hypothesis,
  ipykernel,
  ipython,
  ipywidgets,
  jplephem,
  matplotlib,
  mpmath,
  numpy,
  packaging,
  pandas,
  pyarrow,
  pyerfa,
  pytest-astropy-header,
  pytest-doctestplus,
  pytest-remotedata,
  pytest-xdist,
  pytestCheckHook,
  pytz,
  pyyaml,
  s3fs,
  # optional-dependencies
  scipy,
  setuptools,
  setuptools-scm,
  sortedcontainers,
  threadpoolctl,
  uncompresspy,
}:

buildPythonPackage rec {
  pname = "astropy";
  version = "8.0.0";

  src = fetchFromGitHub {
    owner = "astropy";
    repo = "astropy";
    tag = "v${version}";
    hash = "sha256-pKptFnbhiE6DfsEZ557ugd6nrbWGg2FmEdhp78z+bUM=";
  };

  env = lib.optionalAttrs stdenv.cc.isClang {
    NIX_CFLAGS_COMPILE = "-Wno-error=unused-command-line-argument";
  };

  nativeCheckInputs = [
    hypothesis
    pytestCheckHook
    pytest-xdist
    pytest-astropy-header
    pytest-doctestplus
    pytest-remotedata
    threadpoolctl
    # FIXME remove in 7.2.0
    # see https://github.com/astropy/astropy/pull/18882
    uncompresspy
  ]
  ++ optional-dependencies.recommended;

  preCheck = ''
    export HOME="$(mktemp -d)"

    # See https://github.com/astropy/astropy/issues/17649 and see
    # --hypothesis-profile=ci pytest flag below.
    cp conftest.py $out/
    # https://github.com/NixOS/nixpkgs/issues/255262
    cd "$out"
  '';

  postCheck = ''
    rm conftest.py
  '';

  __darwinAllowLocalNetworking = true;

  build-system = [
    cython
    extension-helpers
    setuptools
    setuptools-scm
  ];

  dependencies = [
    astropy-iers-data
    numpy
    packaging
    pyerfa
    pyyaml
  ];

  optional-dependencies = lib.fix (self: {
    all = [
      certifi
      dask
      h5py
      pyarrow
      beautifulsoup4
      html5lib
      sortedcontainers
      pytz
      jplephem
      mpmath
      asdf
      asdf-astropy
      bottleneck
      fsspec
      s3fs
      uncompresspy
    ]
    ++ self.recommended
    ++ self.ipython
    ++ self.jupyter
    ++ dask.optional-dependencies.array
    ++ fsspec.optional-dependencies.http;

    ipython = [
      ipython
    ];

    jupyter = [
      ipywidgets
      ipykernel
      # ipydatagrid
      pandas
    ]
    ++ self.ipython;

    recommended = [
      scipy
      matplotlib
    ];
  });

  pyproject = true;

  pytestFlags = [
    "--hypothesis-profile=ci"
  ];

  pythonImportsCheck = [ "astropy" ];

  meta = {
    description = "Astronomy/Astrophysics library for Python";
    homepage = "https://www.astropy.org";
    changelog = "https://docs.astropy.org/en/${src.tag}/changelog.html";
    license = lib.licenses.bsd3;

    maintainers = with lib.maintainers; [
      kentjames
      doronbehar
    ];

    platforms = lib.platforms.all;
  };
}
