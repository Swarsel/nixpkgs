{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  defusedxml,
  httpretty,
  poetry-core,
  pytestCheckHook,
  requests,
}:

buildPythonPackage rec {
  pname = "youtube-transcript-api";
  version = "1.2.4";

  src = fetchFromGitHub {
    owner = "jdepoix";
    repo = "youtube-transcript-api";
    tag = "v${version}";
    hash = "sha256-FFLbDiZJR+xqaMMjcBQFYgrdJEofTiBdSNmmlMlrNfY=";
  };

  nativeCheckInputs = [
    httpretty
    pytestCheckHook
  ];

  preCheck = ''
    export PATH=$out/bin:$PATH
  '';

  build-system = [ poetry-core ];

  dependencies = [
    defusedxml
    requests
  ];

  disabledTests = [
    # network access
    "test_fetch__create_consent_cookie_if_needed"
    "test_fetch__with_generic_proxy_reraise_when_blocked"
    "test_fetch__with_proxy_retry_when_blocked"
    "test_fetch__with_webshare_proxy_reraise_when_blocked"
  ];

  pyproject = true;
  pythonImportsCheck = [ "youtube_transcript_api" ];

  pythonRelaxDeps = [
    "defusedxml"
  ];

  meta = {
    description = "Python API which allows you to get the transcripts/subtitles for a given YouTube video";
    homepage = "https://github.com/jdepoix/youtube-transcript-api";
    changelog = "https://github.com/jdepoix/youtube-transcript-api/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "youtube_transcript_api";
  };
}
