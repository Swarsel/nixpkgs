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
  pythonOlder,
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

buildPythonPackage (finalAttrs: {
  pname = "django";
  version = "6.0.7";

  src = fetchFromGitHub {
    owner = "django";
    repo = "django";
    tag = finalAttrs.version;
    hash = "sha256-B28twwEGLcXV0TlQxgRhNBiKhwJd+5f7sL35SkHAkRY=";
  };

  patches = [
    (replaceVars ./6.x/zoneinfo.patch {
      zoneinfo = tzdata + "/share/zoneinfo";
    })
    # prevent tests from messing with our pythonpath
    ./6.x/pythonpath.patch
    # test_incorrect_timezone should raise but doesn't
    ./6.x/disable-failing-test.patch
    # https://code.djangoproject.com/ticket/36997
    # https://github.com/django/django/pull/21019
    ./6.x/invalidate-importlib-cache.patch
  ]
  ++ lib.optionals withGdal [
    (replaceVars ./6.x/gdal.patch {
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
  ++ lib.concatAttrValues finalAttrs.passthru.optional-dependencies;

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

  disabled = pythonOlder "3.12";

  optional-dependencies = {
    argon2 = [ argon2-cffi ];
    bcrypt = [ bcrypt ];
  };

  pyproject = true;

  meta = with lib; {
    description = "High-level Python Web framework that encourages rapid development and clean, pragmatic design";
    homepage = "https://www.djangoproject.com";
    changelog = "https://docs.djangoproject.com/en/${lib.versions.majorMinor finalAttrs.version}/releases/${finalAttrs.version}/";
    license = licenses.bsd3;
    maintainers = with maintainers; [ hexa ];
  };
})
