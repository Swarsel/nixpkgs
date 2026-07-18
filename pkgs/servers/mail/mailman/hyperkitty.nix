{
  lib,
  fetchurl,
  fetchpatch,
  nixosTests,
  python3,
}:

with python3.pkgs;

buildPythonPackage (finalAttrs: {
  pname = "hyperkitty";
  version = "1.3.12";

  src = fetchurl {
    url = "https://gitlab.com/mailman/hyperkitty/-/releases/${finalAttrs.version}/downloads/hyperkitty-${finalAttrs.version}.tar.gz";
    hash = "sha256-3rWCk37FvJ6pwdXYa/t2pNpCm2Dh/qb9aWTnxmfPFh0=";
  };

  patches = [
    # Fix test with mistune >= 3.1
    (fetchpatch {
      hash = "sha256-zo+dK8DFMkHlMrOVSUtelhAq+cxJE4gLG00LvuAlWKA=";
      url = "https://gitlab.com/mailman/hyperkitty/-/commit/2d69f420c603356a639a6b6243e1059a0089b7eb.patch";
    })
    # Fix test with python 3.13
    # https://gitlab.com/mailman/hyperkitty/-/merge_requests/657
    (fetchpatch {
      hash = "sha256-ep9cFZe9/sIfIP80pLBOMYkJKWvNT7DRqg80DQSdRFw=";
      url = "https://gitlab.com/mailman/hyperkitty/-/commit/6c3d402dc0981e545081a3baf13db7e491356e75.patch";
    })
    # Fix test with Django 5.2
    (fetchpatch {
      hash = "sha256-fsJyNsh3l5iR9WgsiEsHlptkN+nlWoop0m2STyucDEc=";
      url = "https://gitlab.com/mailman/hyperkitty/-/commit/e815be11752ac6a3e839b155f0c43808619c56b0.patch";
    })
  ];

  # Some of these are optional runtime dependencies that are not
  # listed as dependencies in pyproject.toml.  To use these, they
  # should be dependencies of the Django Python environment, but not
  # of HyperKitty so they're not included for people who don't need
  # them.
  nativeCheckInputs = [
    beautifulsoup4
    elastic-transport
    elasticsearch
    mock
    whoosh
  ]
  ++ beautifulsoup4.optional-dependencies.lxml;

  checkPhase = ''
    cd $NIX_BUILD_TOP/$sourceRoot
    PYTHONPATH=.:$PYTHONPATH python example_project/manage.py test \
      --settings=hyperkitty.tests.settings_test hyperkitty
  '';

  build-system = [
    pdm-backend
  ];

  dependencies = [
    django
    django-gravatar2
    django-haystack
    django-mailman3
    django-q2
    django-compressor
    django-extensions
    djangorestframework
    flufl-lock
    mistune
    networkx
    psycopg2
    python-dateutil
    robot-detection
  ];

  prePatch = ''
    # Upstream: https://gitlab.com/mailman/hyperkitty/-/commit/b8b7536c2cb7380ec55ed62140617cff8ae36b1d
    substituteInPlace pyproject.toml \
      --replace-fail '"django>=4.2,<5.1"' '"django>=4.2,<5.3"'
  '';

  pyproject = true;
  passthru.tests = { inherit (nixosTests) mailman; };

  meta = {
    description = "Archiver for GNU Mailman v3";
    homepage = "https://www.gnu.org/software/mailman/";
    changelog = "https://docs.mailman3.org/projects/hyperkitty/en/latest/news.html";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ qyliss ];
    platforms = lib.platforms.linux;
  };
})
