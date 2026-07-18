{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # optional-dependencies
  coverage,
  invoke,
  # tests
  ipython,
  # dependencies
  msgpack,
  numpy,
  orjson,
  pandas,
  pint,
  pydantic,
  pymongo,
  pytest,
  pytest-cov,
  pytestCheckHook,
  pythonOlder,
  requests,
  ruamel-yaml,
  # build-system
  setuptools,
  setuptools-scm,
  sphinx,
  sphinx-rtd-theme,
  torch,
  tqdm,
  types-requests,
}:

buildPythonPackage rec {
  pname = "monty";
  version = "2025.3.3";

  src = fetchFromGitHub {
    owner = "materialsvirtuallab";
    repo = "monty";
    tag = "v${version}";
    hash = "sha256-3UoACKJtPm2BrkJP8z7BFrh3baRyL/S3VwCG3K8AQn0=";
  };

  nativeCheckInputs = [
    ipython
    numpy
    pandas
    pydantic
    pymongo
    pytestCheckHook
    torch
    tqdm
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    msgpack
    ruamel-yaml
  ];

  optional-dependencies = rec {
    ci = [
      coverage
      pymongo
      pytest
      pytest-cov
      types-requests
    ]
    ++ optional;

    dev = [ ipython ];

    docs = [
      sphinx
      sphinx-rtd-theme
    ];

    json = [
      orjson
      pandas
      pydantic
      pymongo
    ]
    ++ lib.optionals (pythonOlder "3.13") [
      pint
      torch
    ];

    multiprocessing = [ tqdm ];
    optional = dev ++ json ++ multiprocessing ++ serialization;
    serialization = [ msgpack ];

    task = [
      invoke
      requests
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "monty" ];

  meta = {
    description = "Serves as a complement to the Python standard library by providing a suite of tools to solve many common problems";

    longDescription = "
      Monty implements supplementary useful functions for Python that are not part of the
      standard library. Examples include useful utilities like transparent support for zipped files, useful design
      patterns such as singleton and cached_class, and many more.
    ";

    homepage = "https://github.com/materialsvirtuallab/monty";
    changelog = "https://github.com/materialsvirtuallab/monty/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ psyanticy ];
  };
}
