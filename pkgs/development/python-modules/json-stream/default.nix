{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  httpx,
  iconv,
  json-stream-rs-tokenizer,
  pytestCheckHook,
  requests,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "json-stream";
  version = "2.5.1";

  src = fetchFromGitHub {
    owner = "daggaz";
    repo = "json-stream";
    tag = "v${finalAttrs.version}";
    hash = "sha256-fQuTvd2Kizy8icYoewvJJVDc7FXuXRQkwJfOCka3Eo4=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  dependencies = [ json-stream-rs-tokenizer ] ++ lib.optionals stdenv.hostPlatform.isDarwin [ iconv ];
  disabledTests = [ "test_writer" ];

  optional-dependencies = {
    httpx = [ httpx ];
    requests = [ requests ];
  };

  pyproject = true;
  pythonImportsCheck = [ "json_stream" ];

  meta = {
    description = "Streaming JSON parser";
    homepage = "https://github.com/daggaz/json-stream";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
