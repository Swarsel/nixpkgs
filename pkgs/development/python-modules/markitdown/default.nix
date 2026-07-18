{
  lib,
  stdenv,
  fetchFromGitHub,
  # dependencies
  azure-ai-documentintelligence,
  azure-identity,
  beautifulsoup4,
  buildPythonPackage,
  charset-normalizer,
  defusedxml,
  # passthru
  gitUpdater,
  # build-system
  hatchling,
  lxml,
  magika,
  mammoth,
  markdownify,
  olefile,
  openpyxl,
  pandas,
  pdfminer-six,
  pdfplumber,
  pydub,
  # tests
  pytestCheckHook,
  python-pptx,
  requests,
  speechrecognition,
  xlrd,
  youtube-transcript-api,
}:

let
  isNotAarch64Linux = !(stdenv.hostPlatform.isLinux && stdenv.hostPlatform.isAarch64);
in
buildPythonPackage (finalAttrs: {
  pname = "markitdown";
  version = "0.1.6";

  src = fetchFromGitHub {
    owner = "microsoft";
    repo = "markitdown";
    tag = "v${finalAttrs.version}";
    hash = "sha256-pLL44w2jVj5X5/TmPqSveQe/9WLj0ddDUYPoSQlz+9E=";
  };

  doCheck = isNotAarch64Linux;
  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ hatchling ];

  dependencies = [
    azure-ai-documentintelligence
    azure-identity
    beautifulsoup4
    charset-normalizer
    defusedxml
    lxml
    magika
    mammoth
    markdownify
    olefile
    openpyxl
    pandas
    pdfminer-six
    pdfplumber
    pydub
    python-pptx
    requests
    speechrecognition
    xlrd
    youtube-transcript-api
  ];

  disabledTests = [
    # Require network access
    "test_markitdown_remote"
    "test_module_vectors"
    "test_cli_vectors"
    "test_module_misc"

    # Require optional azure-ai-contentunderstanding, unavailable in nixpkgs.
    # The fallback stubs hit `UserAgentPolicy() takes no arguments`.
    "test_nonexistent_analyzer_raises_value_error"
    "test_cu_registered_before_docintel"
  ];

  pyproject = true;
  # aarch64-linux fails cpuinfo test, because /sys/devices/system/cpu/ does not exist in the sandbox:
  # terminate called after throwing an instance of 'onnxruntime::OnnxRuntimeException'
  #
  # -> Skip all tests that require importing markitdown
  pythonImportsCheck = lib.optionals isNotAarch64Linux [ "markitdown" ];

  pythonRelaxDeps = [
    "magika"
    "mammoth"
    "youtube-transcript-api"
  ];

  sourceRoot = "${finalAttrs.src.name}/packages/markitdown";

  passthru.updateScript = gitUpdater {
    # Skip PEP 440 pre-release tags.
    ignoredVersions = "(a|b|rc)[0-9]+$";
    # Drop the "v" tag prefix before version comparison.
    rev-prefix = "v";
  };

  meta = {
    description = "Python tool for converting files and office documents to Markdown";
    homepage = "https://github.com/microsoft/markitdown";
    changelog = "https://github.com/microsoft/markitdown/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ malik ];
  };
})
