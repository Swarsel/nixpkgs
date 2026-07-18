{
  lib,
  stdenv,
  fetchFromGitHub,
  # tests
  aiosmtpd,
  # optional-dependencies
  argon2-cffi,
  # dependencies
  asgiref,
  bcrypt,
  buildPythonPackage,
  docutils,
  gdal,
  geoip2,
  # patched in
  geos,
  jinja2,
  numpy,
  pillow,
  pylibmc,
  pymemcache,
  python,
  pytz,
  pyyaml,
  redis,
  replaceVars,
  selenium,
  # build-system
  setuptools,
  sqlparse,
  tblib,
  tzdata,
  withGdal ? false,
}:

buildPythonPackage rec {
  pname = "django";
  version = "5.2.16";

  src = fetchFromGitHub {
    owner = "django";
    repo = "django";
    tag = version;
    hash = "sha256-DZa3OkqnrgXp1A/HerKYdUdanvi5jxHndo1DV4RVs0M=";
  };

  patches = [
    (replaceVars ./5.2/zoneinfo.patch {
      zoneinfo = tzdata + "/share/zoneinfo";
    })
    # prevent tests from messing with our pythonpath
    ./5.2/pythonpath.patch
    # disable test that expects timezone issues
    ./5.2/disable-failing-test.patch
  ]
  ++ lib.optionals withGdal [
    (replaceVars ./5.2/gdal.patch {
      extension = stdenv.hostPlatform.extensions.sharedLibrary;
      gdal = gdal;
      geos = geos;
    })
  ];

  postPatch = ''
    substituteInPlace tests/utils_tests/test_autoreload.py \
      --replace-fail "/usr/bin/python" "${python.interpreter}"
  '';

  nativeCheckInputs = [
    # tests/requirements/py3.txt
    aiosmtpd
    docutils
    geoip2
    jinja2
    numpy
    pillow
    pylibmc
    pymemcache
    pyyaml
    pytz
    redis
    selenium
    tblib
    tzdata
  ]
  ++ lib.concatAttrValues optional-dependencies;

  preCheck = ''
    # make sure the installed library gets imported
    rm -rf django

    # fails to import github_links from docs/_ext/github_links.py
    rm tests/sphinx/test_github_links.py

    # provide timezone data, works only on linux
    export TZDIR=${tzdata}/${python.sitePackages}/tzdata/zoneinfo

    export PYTHONPATH=$PWD/docs/_ext:$PYTHONPATH
  '';

  checkPhase = ''
    runHook preCheck

    pushd tests
    # without --parallel=1, tests fail with an "unexpected error due to a database lock" on Darwin
    ${python.interpreter} runtests.py --settings=test_sqlite ${lib.optionalString stdenv.hostPlatform.isDarwin "--parallel=1"}
    popd

    runHook postCheck
  '';

  __darwinAllowLocalNetworking = true;
  build-system = [ setuptools ];

  dependencies = [
    asgiref
    sqlparse
  ];

  optional-dependencies = {
    argon2 = [ argon2-cffi ];
    bcrypt = [ bcrypt ];
  };

  pyproject = true;

  meta = {
    description = "High-level Python Web framework that encourages rapid development and clean, pragmatic design";
    homepage = "https://www.djangoproject.com";
    changelog = "https://docs.djangoproject.com/en/${lib.versions.majorMinor version}/releases/${version}/";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ hexa ];
  };
}
