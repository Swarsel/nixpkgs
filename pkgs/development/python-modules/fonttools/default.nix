{
  lib,
  stdenv,
  fetchFromGitHub,
  addBinToPathHook,
  brotli,
  brotlicffi,
  buildPythonPackage,
  isPyPy,
  lxml,
  lz4,
  matplotlib,
  munkres,
  pycairo,
  pytestCheckHook,
  pythonOlder,
  scipy,
  setuptools,
  setuptools-scm,
  skia-pathops,
  sympy,
  uharfbuzz,
  unicodedata2,
  xattr,
  zopfli,
}:

buildPythonPackage (finalAttrs: {
  pname = "fonttools";
  version = "4.63.0";

  src = fetchFromGitHub {
    owner = "fonttools";
    repo = "fonttools";
    tag = finalAttrs.version;
    hash = "sha256-XTE18TKpIa4MpbJ5tcHwCyLk3Q6CV/ElzMtddG86HJA=";
  };

  nativeCheckInputs = [
    addBinToPathHook
    pytestCheckHook
  ]
  ++ lib.concatLists (
    lib.attrVals (
      [
        "woff"
        # "interpolatable" is not included because it only contains 2 tests at the time of writing but adds 270 extra dependencies
        "ufo"
      ]
      ++
        lib.optionals (lib.meta.availableOn stdenv.hostPlatform skia-pathops && !skia-pathops.meta.broken)
          [
            "pathops" # broken
          ]
      ++ [ "repacker" ]
    ) finalAttrs.passthru.optional-dependencies
  );

  build-system = [
    setuptools
    setuptools-scm
  ];

  # Timestamp tests have timing issues probably related
  # to our file timestamp normalization
  disabledTests = [
    "test_recalc_timestamp_ttf"
    "test_recalc_timestamp_otf"
    "test_ttcompile_timestamp_calcs"
  ];

  optional-dependencies =
    let
      extras = {
        graphite = [ lz4 ];

        interpolatable = [
          pycairo
          (if isPyPy then munkres else scipy)
        ];

        lxml = [ lxml ];
        pathops = [ skia-pathops ];
        plot = [ matplotlib ];
        repacker = [ uharfbuzz ];
        symfont = [ sympy ];
        type1 = lib.optional stdenv.hostPlatform.isDarwin xattr;
        ufo = [ ];
        unicode = lib.optional (pythonOlder "3.15") unicodedata2;

        woff = [
          (if isPyPy then brotlicffi else brotli)
          zopfli
        ];
      };
    in
    extras // { all = lib.concatLists (lib.attrValues extras); };

  pyproject = true;
  pythonImportsCheck = [ "fontTools" ];

  meta = {
    description = "Library to manipulate font files from Python";
    homepage = "https://github.com/fonttools/fonttools";
    changelog = "https://github.com/fonttools/fonttools/blob/${finalAttrs.src.tag}/NEWS.rst";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sternenseemann ];
  };
})
