{
  lib,
  stdenv,
  fetchFromGitHub,
  beautifulsoup4,
  bitmath,
  bpylist2,
  buildPythonPackage,
  click,
  mako,
  markdown2,
  more-itertools,
  objexplore,
  packaging,
  pathvalidate,
  pip,
  psutil,
  ptpython,
  pytest-mock,
  # tests
  pytestCheckHook,
  pytimeparse2,
  pyyaml,
  requests,
  rich,
  rich-theme-manager,
  setuptools,
  shortuuid,
  strpdatetime,
  tenacity,
  textx,
  toml,
  tzdata,
  utitools,
  whenever,
  wrapt,
  writableTmpDirAsHomeHook,
  wurlitzer,
  xdg-base-dirs,
}:

buildPythonPackage (finalAttrs: {
  pname = "osxphotos";
  version = "0.76.1";

  src = fetchFromGitHub {
    owner = "RhetTbull";
    repo = "osxphotos";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ZpY9T4Y0ZQmBgbFM0S/AuVw9YOpuM6V6CUW5GUHTjXI=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-mock
    writableTmpDirAsHomeHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    beautifulsoup4
    bitmath
    bpylist2
    click
    mako
    markdown2
    more-itertools
    objexplore
    packaging
    pathvalidate
    pip
    psutil
    ptpython
    pytimeparse2
    pyyaml
    requests
    rich
    rich-theme-manager
    shortuuid
    strpdatetime
    tenacity
    textx
    toml
    tzdata
    utitools
    whenever
    wrapt
    wurlitzer
    xdg-base-dirs
  ];

  disabledTests = [
    "test_datetime_naive_to_local"
    "test_from_to_date_tz"
    "test_function_url"
    "test_get_local_tz"
    "test_query_from_to_date_alt_location"
    "test_query_function_url"
  ];

  pyproject = true;
  pythonImportsCheck = [ "osxphotos" ];

  pythonRelaxDeps = [
    "bitmath"
    "mako"
    "more-itertools"
    "objexplore"
    "rich"
    "textx"
    "tenacity"
    "whenever"
  ];

  meta = {
    description = "Export photos from Apple's macOS Photos app and query the Photos library database to access metadata about images";
    homepage = "https://github.com/RhetTbull/osxphotos";
    changelog = "https://github.com/RhetTbull/osxphotos/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ sigmanificient ];
    # missing utitools dependency
    broken = true && stdenv.hostPlatform.isDarwin;
  };
})
