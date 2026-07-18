{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # optional-dependencies
  click,
  fastapi,
  huggingface-hub,
  jinja2,
  # dependencies
  jsonschema,
  llguidance,
  numpy,
  # tests
  openai,
  opencv-python-headless,
  pillow,
  pycountry,
  pydantic,
  pydantic-extra-types,
  pydantic-settings,
  pytestCheckHook,
  requests,
  sentencepiece,
  # build-system
  setuptools,
  soundfile,
  soxr,
  tiktoken,
  typing-extensions,
  uvicorn,
  uvloop,
}:

buildPythonPackage (finalAttrs: {
  pname = "mistral-common";
  version = "1.11.5";

  src = fetchFromGitHub {
    owner = "mistralai";
    repo = "mistral-common";
    tag = "v${finalAttrs.version}";
    hash = "sha256-vm7u+EWuqjguccezlN+fKdTl8CL081ah3OccpenbpT0=";
  };

  nativeCheckInputs = [
    openai
    pycountry
    pytestCheckHook
    uvicorn
  ]
  ++ finalAttrs.finalPackage.optional-dependencies.all;

  build-system = [
    setuptools
  ];

  dependencies = [
    jsonschema
    numpy
    pillow
    pydantic
    pydantic-extra-types
    requests
    tiktoken
    typing-extensions
  ];

  disabledTests = [
    # AssertionError, Extra items in the right set
    "test_openai_chat_fields"
  ];

  optional-dependencies =
    let
      self = finalAttrs.finalPackage.optional-dependencies;
    in
    {
      all =
        self.opencv
        ++ self.sentencepiece
        ++ self.audio
        ++ self.image
        ++ self.guidance
        ++ self.hf-hub
        ++ self.server;

      audio = self.soundfile ++ self.soxr;

      guidance = [
        jinja2
        llguidance
      ];

      hf-hub = [
        huggingface-hub
      ];

      image = self.opencv;

      opencv = [
        opencv-python-headless
      ];

      sentencepiece = [
        sentencepiece
      ];

      server = [
        click
        fastapi
        pydantic-settings
        uvloop
      ]
      ++ fastapi.optional-dependencies.standard;

      soundfile = [
        soundfile
      ];

      soxr = [
        soxr
      ];
    };

  pyproject = true;
  pythonImportsCheck = [ "mistral_common" ];

  meta = {
    description = "Tools to help you work with Mistral models";
    homepage = "https://github.com/mistralai/mistral-common";
    changelog = "https://github.com/mistralai/mistral-common/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ bgamari ];
  };
})
