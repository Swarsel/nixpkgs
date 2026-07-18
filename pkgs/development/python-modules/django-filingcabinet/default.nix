{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  camelot,
  celery,
  django,
  django-filter,
  django-json-widget,
  django-taggit,
  django-treebeard,
  djangorestframework,
  factory-boy,
  feedgen,
  fetchPnpmDeps,
  jsonschema,
  markdown,
  nh3,
  nodejs,
  pikepdf,
  playwright-driver,
  pnpmConfigHook,
  pnpm_10,
  poppler-utils,
  pycryptodome,
  pypdf,
  pytesseract,
  pytest-django,
  pytest-factoryboy,
  pytest-playwright,
  pytestCheckHook,
  python-poppler,
  reportlab,
  setuptools,
  wand,
  zipstream-ng,
}:
let
  pnpm = pnpm_10;
in
buildPythonPackage rec {
  pname = "django-filingcabinet";
  version = "0.17-unstable-2025-08-14";

  src = fetchFromGitHub {
    owner = "okfde";
    repo = "django-filingcabinet";
    # No release tagged yet on GitHub
    # https://github.com/okfde/django-filingcabinet/issues/69
    rev = "e1713921d6d14e0abc8b81315545d7fb6f08c39f";
    hash = "sha256-R/JNI+PZb0H09ZoYCGV3nbAowkf/YlKia4xkgAgqoNM=";
  };

  postPatch = ''
    # zipstream is discontinued and outdated
    # https://github.com/okfde/django-filingcabinet/issues/90
    substituteInPlace pyproject.toml \
      --replace-fail "zipstream" "zipstream-ng"
  '';

  nativeBuildInputs = [
    nodejs
    pnpmConfigHook
    pnpm
  ];

  postBuild = ''
    pnpm run build
  '';

  # Playwright tests not supported on RiscV yet
  doCheck = lib.meta.availableOn stdenv.hostPlatform playwright-driver.browsers;

  nativeCheckInputs = [
    poppler-utils
    pytest-django
    pytest-factoryboy
    pytest-playwright
    pytestCheckHook
  ];

  preCheck = ''
    export DJANGO_SETTINGS_MODULE="test_project.settings"
  ''
  + lib.optionalString (!stdenv.hostPlatform.isRiscV) ''
    export PLAYWRIGHT_BROWSERS_PATH="${playwright-driver.browsers}"
  '';

  postInstall = ''
    cp -r build $out/
  '';

  build-system = [ setuptools ];

  dependencies = [
    celery
    django
    django-filter
    django-json-widget
    django-taggit
    django-treebeard
    djangorestframework
    feedgen
    jsonschema
    markdown
    nh3
    pikepdf
    pycryptodome
    pypdf
    python-poppler
    reportlab
    wand
    zipstream-ng
  ];

  disabledTests = [
    # AssertionError: Locator expected to be visible
    "test_keyboard_scroll"
    "test_number_input_scroll"
    # playwright._impl._errors.TimeoutError: Locator.click: Timeout 30000ms exceeded
    "test_sidebar_hide"
    "test_show_search_bar"
    # Unable to launch browser
    "test_document_viewer"
  ];

  optional-dependencies = {
    ocr = [ pytesseract ];
    tabledetection = [ camelot ];
    # Dependencies not yet packaged
    #webp = [ webp ];
    #annotate = [ fcdocs-annotate ];
  };

  pnpmDeps = fetchPnpmDeps {
    inherit
      pname
      version
      src
      pnpm
      ;

    fetcherVersion = 3;
    hash = "sha256-p+RpEDVbdYmeSD4bB0oUMrTpsVDGYkqME13awnoTNd0=";
  };

  pyproject = true;
  pythonImportsCheck = [ "filingcabinet" ];

  meta = {
    description = "Django app that manages documents with pages, annotations and collections";
    homepage = "https://github.com/okfde/django-filingcabinet";
    changelog = "https://github.com/feincms/django-cabinet/blob/${version}/CHANGELOG.rst";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.onny ];
  };
}
