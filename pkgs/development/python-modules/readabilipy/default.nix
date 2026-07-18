{
  lib,
  fetchFromGitHub,
  beautifulsoup4,
  buildNpmPackage,
  buildPythonPackage,
  html5lib,
  lxml,
  nodejs,
  pytestCheckHook,
  readabilipy,
  regex,
  setuptools,
  testers,
}:

buildPythonPackage rec {
  pname = "readabilipy";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "alan-turing-institute";
    repo = "ReadabiliPy";
    tag = "v${version}";
    hash = "sha256-FYdSbq3rm6fBHm5fDRAB0airX9fNcUGs1wHN4i6mnG0=";
  };

  patches = [
    # Fix test failures with Python 3.13.6
    # https://github.com/alan-turing-institute/ReadabiliPy/pull/116
    ./python3.13.6-compatibility.patch
  ];

  postPatch = ''
    ln -s $javascript/lib/node_modules/ReadabiliPy/node_modules readabilipy/javascript/node_modules
    echo "recursive-include readabilipy/javascript *" >MANIFEST.in
  '';

  nativeCheckInputs = [
    pytestCheckHook
    nodejs
  ];

  postInstall = ''
    wrapProgram $out/bin/readabilipy \
      --prefix PATH : ${nodejs}/bin
  '';

  build-system = [ setuptools ];

  dependencies = [
    beautifulsoup4
    html5lib
    lxml
    regex
  ];

  disabledTestPaths = [
    # Exclude benchmarks
    "tests/test_benchmarking.py"
  ];

  disabledTests = [
    # IndexError: list index out of range
    "test_html_blacklist"
    "test_prune_div_with_one_empty_span"
    "test_prune_div_with_one_whitespace_paragraph"
    "test_empty_page"
    "test_contentless_page"
    "test_extract_title"
    "test_iframe_containing_tags"
    "test_iframe_with_source"
  ];

  javascript = buildNpmPackage {
    inherit version;
    pname = "readabilipy-javascript";
    src = src;

    postPatch = ''
      cp ${./package-lock.json} package-lock.json
    '';

    npmDepsHash = "sha256-1yp80TwRbE/NcMa0qrml0TlSZJ6zwSTmj+zDjBejko8=";
    dontNpmBuild = true;
    sourceRoot = "${src.name}/readabilipy/javascript";
  };

  pyproject = true;
  pythonImportsCheck = [ "readabilipy" ];

  passthru = {
    tests.version = testers.testVersion {
      version = "${version} (Readability.js supported: yes)";
      command = "readabilipy --version";
      package = readabilipy;
    };
  };

  meta = {
    description = "HTML content extractor";
    homepage = "https://github.com/alan-turing-institute/ReadabiliPy";
    changelog = "https://github.com/alan-turing-institute/ReadabiliPy/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "readabilipy";
  };
}
