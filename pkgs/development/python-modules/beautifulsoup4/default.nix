{
  lib,
  buildPythonPackage,
  # optional-dependencies
  chardet,
  charset-normalizer,
  faust-cchardet,
  fetchPypi,
  fetchpatch,
  # build-system
  hatchling,
  # for passthru.tests
  html-sanitizer,
  html5lib,
  lxml,
  markdownify,
  mechanicalsoup,
  nbconvert,
  # tests
  pytestCheckHook,
  # dependencies
  soupsieve,
  # docs
  sphinxHook,
  subliminal,
  typing-extensions,
  wagtail,
}:

buildPythonPackage rec {
  pname = "beautifulsoup4";
  version = "4.14.3";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-YpKxxRhtNWu6Zp759/BRdXCZVlrZraXdYwvZ3l+n+4Y=";
  };

  outputs = [
    "out"
    "doc"
  ];

  patches = [
    # Fix tests with python 3.13.10 / 3.14.1
    (fetchpatch {
      excludes = [ "CHANGELOG" ];
      hash = "sha256-DJl1pey0NdJH+SyBH9+y6gwUvQCmou0D9xcRAEV8OBw=";
      url = "https://git.launchpad.net/beautifulsoup/patch/?id=55f655ffb7ef03bdd1df0f013743831fe54e3c7a";
    })
  ];

  nativeBuildInputs = [ sphinxHook ];

  nativeCheckInputs = [
    pytestCheckHook
  ]
  ++ lib.concatAttrValues optional-dependencies;

  build-system = [ hatchling ];

  dependencies = [
    soupsieve
    typing-extensions
  ];

  disabledTests = [
    # fail with latest libxml, by not actually rejecting
    "test_rejected_markup"
    "test_rejected_input"
  ];

  optional-dependencies = {
    cchardet = [ faust-cchardet ];
    chardet = [ chardet ];
    charset-normalizer = [ charset-normalizer ];
    html5lib = [ html5lib ];
    lxml = [ lxml ];
  };

  pyproject = true;
  pythonImportsCheck = [ "bs4" ];

  passthru.tests = {
    inherit
      html-sanitizer
      markdownify
      mechanicalsoup
      nbconvert
      subliminal
      wagtail
      ;
  };

  meta = {
    description = "HTML and XML parser";
    homepage = "http://crummy.com/software/BeautifulSoup/bs4/";
    changelog = "https://git.launchpad.net/beautifulsoup/tree/CHANGELOG?h=${version}";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
