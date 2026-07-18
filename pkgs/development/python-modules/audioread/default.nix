{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  ffmpeg-headless,
  poetry-core,
  pytestCheckHook,
  standard-aifc,
  standard-sunau,
}:

buildPythonPackage (finalAttrs: {
  pname = "audioread";
  version = "3.1.0";

  src = fetchFromGitHub {
    owner = "sampsyo";
    repo = "audioread";
    tag = "v${finalAttrs.version}";
    hash = "sha256-QvgwjUGuzeHH69YAdZdImjMT+9t4YxAukbuZKk0lBro=";
  };

  nativeCheckInputs = [
    ffmpeg-headless
    pytestCheckHook
  ];

  build-system = [ poetry-core ];

  dependencies = [
    standard-aifc
    standard-sunau
  ];

  pyproject = true;

  meta = {
    description = "Cross-platform audio decoding";
    homepage = "https://github.com/sampsyo/audioread";
    license = lib.licenses.mit;
  };
})
