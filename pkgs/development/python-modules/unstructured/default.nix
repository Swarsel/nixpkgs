{
  lib,
  fetchFromGitHub,
  # core networking and async dependencies
  anyio,
  backoff,
  # core parsing and processing
  beautifulsoup4,
  black,
  buildPythonPackage,
  certifi,
  # core system utilities
  cffi,
  chardet,
  charset-normalizer,
  click,
  coverage,
  cryptography,
  # core data handling
  dataclasses-json,
  deepdiff,
  emoji,
  # xslx
  et-xmlfile,
  filetype,
  freezegun,
  grpcio,
  h11,
  html5lib,
  httpcore,
  httpx,
  idna,
  # markdown
  importlib-metadata,
  joblib,
  # huggingface
  langdetect,
  # unstructured-paddleocr,
  # pptx
  lxml,
  # document format support
  markdown,
  marshmallow,
  # , label-studio-sdk
  mypy,
  mypy-extensions,
  nest-asyncio,
  networkx,
  # jsonpath-python,
  nltk,
  nltk-data,
  numba,
  numpy,
  olefile,
  # pdf
  opencv-python,
  openpyxl,
  orderly-set,
  packaging,
  paddlepaddle,
  pandas,
  pdf2image,
  pdfminer-six,
  pdfplumber,
  # pi-heif,
  pikepdf,
  pillow,
  psutil,
  pycparser,
  pypandoc,
  pypdf,
  pytest-cov-stub,
  pytest-mock,
  # test dependencies
  pytestCheckHook,
  python-dateutil,
  python-docx,
  python-iso639,
  python-magic,
  python-oxmsg,
  python-pptx,
  # unstructured-pytesseract,
  # optional dependencies
  # csv
  pytz,
  rapidfuzz,
  regex,
  requests,
  requests-toolbelt,
  sacremoses,
  sentencepiece,
  # build-system
  setuptools,
  six,
  sniffio,
  soupsieve,
  symlinkJoin,
  torch,
  tqdm,
  transformers,
  typing-extensions,
  typing-inspect,
  tzdata,
  unstructured-client,
  # local-inference
  unstructured-inference,
  urllib3,
  vcrpy,
  webencodings,
  wrapt,
  xlrd,
  xlsxwriter,
  zipp,
}:
let
  version = "0.18.31";

  # unstructured downloads these NLTK corpora at import time unless they are already on
  # nltk.data.path, which fails in offline or read-only builds. Bundle them and register
  # the directory in postPatch. It must be named "nltk_data": unstructured's resolver
  # uses paths ending in "nltk_data" as-is and appends "/nltk_data" to any others.
  nltkData = symlinkJoin {
    name = "nltk_data";

    paths = with nltk-data; [
      averaged-perceptron-tagger-eng
      punkt-tab
    ];
  };
in
buildPythonPackage rec {
  inherit version;
  pname = "unstructured";

  src = fetchFromGitHub {
    owner = "Unstructured-IO";
    repo = "unstructured";
    tag = version;
    hash = "sha256-2RGwuCVnoKkqYFVzW7nWuaB9B4IguKSfLO7u1qqAALk=";
  };

  postPatch = ''
    substituteInPlace unstructured/nlp/tokenize.py \
      --replace-fail 'import nltk' 'import nltk; nltk.data.path.append("${nltkData}")'
  '';

  # the import-time NLTK download is handled via nltkData above, but the test suite has
  # further offline/data requirements that are not yet verified, so keep it disabled.
  doCheck = false;

  nativeCheckInputs = [
    pytestCheckHook
    black
    coverage
    click
    freezegun
    mypy
    pytest-cov-stub
    pytest-mock
    vcrpy
    grpcio
  ];

  build-system = [ setuptools ];

  dependencies = [
    # Base dependencies
    anyio
    backoff
    beautifulsoup4
    certifi
    cffi
    chardet
    charset-normalizer
    click
    cryptography
    dataclasses-json
    deepdiff
    emoji
    filetype
    h11
    html5lib
    httpcore
    httpx
    idna
    joblib
    # jsonpath-python
    langdetect
    lxml
    marshmallow
    mypy-extensions
    nest-asyncio
    nltk
    numba
    numpy
    olefile
    orderly-set
    packaging
    psutil
    pycparser
    pypdf
    python-dateutil
    python-iso639
    python-magic
    python-oxmsg
    rapidfuzz
    regex
    requests
    requests-toolbelt
    six
    sniffio
    soupsieve
    tqdm
    typing-extensions
    typing-inspect
    unstructured-client
    urllib3
    webencodings
    wrapt
  ];

  optional-dependencies = rec {
    all-docs = csv ++ docx ++ epub ++ pdf ++ req-markdown ++ odt ++ org ++ pptx ++ xlsx;

    csv = [
      numpy
      pandas
      python-dateutil
      pytz
      tzdata
    ];

    docx = [
      lxml
      python-docx
      typing-extensions
    ];

    epub = [ pypandoc ];

    huggingface = [
      langdetect
      sacremoses
      sentencepiece
      torch
      transformers
    ];

    odt = [
      lxml
      pypandoc
      python-docx
      typing-extensions
    ];

    org = [
      pypandoc
    ];

    paddleocr = [
      opencv-python
      # paddlepaddle # 3.12 not supported for now
      pdf2image
      # unstructured-paddleocr
    ];

    pdf = [
      pdf2image
      pdfminer-six
      pdfplumber
      # pi-heif
      pikepdf
      pypdf
      unstructured-inference
      # unstructured-pytesseract
    ];

    pptx = [
      lxml
      pillow
      python-pptx
      xlsxwriter
    ];

    req-markdown = [
      importlib-metadata
      markdown
      zipp
    ];

    xlsx = [
      et-xmlfile
      networkx
      numpy
      openpyxl
      pandas
      xlrd
    ];
  };

  pyproject = true;

  pythonImportsCheck = [
    "unstructured"
    # exercises the bundled NLTK corpora lookup, so the build catches an attempted download
    "unstructured.nlp.tokenize"
  ];

  meta = {
    description = "Open source libraries and APIs to build custom preprocessing pipelines for labeling, training, or production machine learning pipelines";
    homepage = "https://github.com/Unstructured-IO/unstructured";
    changelog = "https://github.com/Unstructured-IO/unstructured/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ happysalada ];
    mainProgram = "unstructured-ingest";
  };
}
