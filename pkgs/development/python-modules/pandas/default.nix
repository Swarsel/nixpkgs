{
  lib,
  stdenv,
  fetchFromGitHub,
  # tests
  adv_cmds,
  # optionals
  beautifulsoup4,
  blosc2,
  bottleneck,
  buildPythonPackage,
  # build-system
  cython_3_1,
  fsspec,
  gcsfs,
  glibc,
  html5lib,
  hypothesis,
  jinja2,
  lxml,
  matplotlib,
  meson,
  meson-python,
  numba,
  numexpr,
  # propagates
  numpy,
  odfpy,
  openpyxl,
  pkg-config,
  psycopg2,
  pyarrow,
  pymysql,
  pyqt5,
  pyreadstat,
  pytest-asyncio,
  pytest-xdist,
  pytestCheckHook,
  python,
  python-dateutil,
  pytz,
  pyxlsb,
  qtpy,
  runtimeShell,
  s3fs,
  scipy,
  sqlalchemy,
  tables,
  tabulate,
  tzdata,
  versioneer,
  wheel,
  xarray,
  xlrd,
  xlsxwriter,
  zstandard,
}:

let
  pandas = buildPythonPackage rec {
    pname = "pandas";
    version = "3.0.4";

    src = fetchFromGitHub {
      owner = "pandas-dev";
      repo = "pandas";
      tag = "v${version}";
      hash = "sha256-cPnvBVs5xXjbRoj6KU/KeNn+To9oue7H0OBaJ2JdJG4=";

      postFetch = ''
        sed -i 's/git_refnames = "[^"]*"/git_refnames = " (tag: ${src.tag})"/' $out/pandas/_version.py
      '';
    };

    # A NOTE regarding the Numpy version relaxing: Both Numpy versions 1.x &
    # 2.x are supported. However upstream wants to always build with Numpy 2,
    # and with it to still be able to run with a Numpy 1 or 2. We insist to
    # perform this substitution even though python3.pkgs.numpy is of version 2
    # nowadays, because our ecosystem unfortunately doesn't allow easily
    # separating runtime and build-system dependencies. See also:
    #
    # https://discourse.nixos.org/t/several-comments-about-priorities-and-new-policies-in-the-python-ecosystem/51790
    #
    # Being able to build (& run) with Numpy 1 helps for python environments
    # that override globally the `numpy` attribute to point to `numpy_1`.
    postPatch = ''
      substituteInPlace pyproject.toml \
        --replace-fail "numpy>=2.0.0" numpy
    '';

    doCheck = false; # various infinite recursions

    nativeCheckInputs = [
      hypothesis
      pytest-asyncio
      pytest-xdist
      pytestCheckHook
    ]
    ++ lib.concatAttrValues optional-dependencies
    ++ lib.optionals (stdenv.hostPlatform.isLinux) [
      # for locale executable
      glibc
    ]
    ++ lib.optionals (stdenv.hostPlatform.isDarwin) [
      # for locale executable
      adv_cmds
    ];

    # Tests have relative paths, and need to reference compiled C extensions
    # so change directory where `import .test` is able to be resolved
    preCheck = ''
      export HOME=$TMPDIR
      cd $out/${python.sitePackages}/pandas
    ''
    # TODO: Get locale and clipboard support working on darwin.
    #       Until then we disable the tests.
    + lib.optionalString stdenv.hostPlatform.isDarwin ''
      # Fake the impure dependencies pbpaste and pbcopy
      echo "#!${runtimeShell}" > pbcopy
      echo "#!${runtimeShell}" > pbpaste
      chmod a+x pbcopy pbpaste
      export PATH=$(pwd):$PATH
    '';

    __darwinAllowLocalNetworking = true;

    build-system = [
      cython_3_1
      meson-python
      meson
      numpy
      pkg-config
      versioneer
      wheel
    ];

    dependencies = [
      numpy
      python-dateutil
      pytz
      tzdata
    ];

    disabledTestMarks = [
      # https://github.com/pandas-dev/pandas/blob/main/test_fast.sh
      "single_cpu"
      "slow"
      "network"
      "db"
      "slow_arm"
    ];

    disabledTests = [
      # AssertionError: Did not see expected warning of class 'FutureWarning'
      "test_parsing_tzlocal_deprecated"
    ]
    ++ lib.optionals (stdenv.hostPlatform.isDarwin && stdenv.hostPlatform.isAarch64) [
      # tests/generic/test_finalize.py::test_binops[and_-args4-right] - AssertionError: assert {} == {'a': 1}
      "test_binops"
      # These tests are unreliable on aarch64-darwin. See https://github.com/pandas-dev/pandas/issues/38921.
      "test_rolling"
    ]
    ++ lib.optional stdenv.hostPlatform.is32bit [
      # https://github.com/pandas-dev/pandas/issues/37398
      "test_rolling_var_numerical_issues"
    ];

    # don't max out build cores, it breaks tests
    dontUsePytestXdist = true;
    enableParallelBuilding = true;

    optional-dependencies =
      let
        extras = {
          aws = [ s3fs ];

          clipboard = [
            pyqt5
            qtpy
          ];

          compression = [ zstandard ];

          computation = [
            scipy
            xarray
          ];

          excel = [
            odfpy
            openpyxl
            pyxlsb
            xlrd
            xlsxwriter
          ];

          feather = [ pyarrow ];
          fss = [ fsspec ];

          gcp = [
            gcsfs
            # TODO: pandas-gqb
          ];

          hdf5 = [
            blosc2
            tables
          ];

          html = [
            beautifulsoup4
            html5lib
            lxml
          ];

          mysql = [
            sqlalchemy
            pymysql
          ];

          output_formatting = [
            jinja2
            tabulate
          ];

          parquet = [ pyarrow ];

          performance = [
            bottleneck
            numba
            numexpr
          ];

          plot = [ matplotlib ];

          postgresql = [
            sqlalchemy
            psycopg2
          ];

          spss = [ pyreadstat ];
          sql-other = [ sqlalchemy ];
          xml = [ lxml ];
        };
      in
      extras // { all = lib.concatLists (lib.attrValues extras); };

    pyproject = true;

    pytestFlags = [
      # https://github.com/pandas-dev/pandas/issues/54907
      "--no-strict-data-files"
      "--numprocesses=4"
    ];

    pythonImportsCheck = [ "pandas" ];

    passthru.tests.pytest = pandas.overridePythonAttrs (_: {
      doCheck = true;
    });

    meta = {
      description = "Powerful data structures for data analysis, time series, and statistics";

      longDescription = ''
        Flexible and powerful data analysis / manipulation library for
        Python, providing labeled data structures similar to R data.frame
        objects, statistical functions, and much more.
      '';

      homepage = "https://pandas.pydata.org";
      # pandas devs no longer test i686, it's commonly broken
      # broken = stdenv.hostPlatform.isi686;
      changelog = "https://pandas.pydata.org/docs/whatsnew/index.html";
      license = lib.licenses.bsd3;

      maintainers = with lib.maintainers; [
        raskin
      ];

      downloadPage = "https://github.com/pandas-dev/pandas";
    };
  };
in
pandas
