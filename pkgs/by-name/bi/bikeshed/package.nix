{
  lib,
  fetchPypi,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "bikeshed";
  version = "7.0.7";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-s+NHSOHqJl89/sB5b3SWS+dT7WpsSv9tedoOfuDA2ls=";
  };

  patches = [ ./remove-install-check.patch ];

  checkPhase = ''
    $out/bin/bikeshed test
  '';

  build-system = [ python3Packages.setuptools ];

  dependencies = with python3Packages; [
    about-time
    aiofiles
    aiohttp
    aiosignal
    alive-progress
    async-timeout
    attrs
    cddlparser
    certifi
    charset-normalizer
    cssselect
    frozenlist
    html5lib
    idna
    isodate
    json-home-client
    kdl-py
    lxml
    multidict
    pillow
    pygments
    requests
    result
    setuptools
    six
    tenacity
    typing-extensions
    uri-template
    urllib3
    webencodings
    widlparser
    yarl
  ];

  pyproject = true;
  pythonImportsCheck = [ "bikeshed" ];
  pythonRelaxDeps = true;

  meta = {
    description = "Preprocessor for anyone writing specifications that converts source files into actual specs";

    longDescription = ''
      Bikeshed is a pre-processor for spec documents, turning a source document
      (containing only the actual spec content, plus several shorthands for linking
      to terms and other things) into a final spec document, with appropriate boilerplate,
      bibliography, indexes, etc all filled in. It's used on specs for CSS
      and many other W3C working groups, WHATWG, the C++ standards committee, and elsewhere!
    '';

    homepage = "https://tabatkins.github.io/bikeshed/";
    license = lib.licenses.cc0;

    maintainers = with lib.maintainers; [
      matthiasbeyer
      hemera
    ];

    mainProgram = "bikeshed";
  };
})
