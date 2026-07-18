{
  lib,
  fetchFromGitHub,
  aiovban-pyaudio,
  buildPythonPackage,
  music-assistant,
  pytestCheckHook,
  textual,
  uv-build,
}:

buildPythonPackage (finalAttrs: {
  pname = "aiovban";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "wmbest2";
    repo = "aiovban";
    tag = "v${finalAttrs.version}";
    hash = "sha256-yPp4+aQGJISTIFI/OoO7+mAR8daEytxrQn21SsFWEyc=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "uv_build>=0.10.0,<0.11.0" "uv_build"
  '';

  # avoid infinite recursion with aiovban-pyaudio
  doCheck = false;

  nativeCheckInputs = [
    aiovban-pyaudio
    pytestCheckHook
  ]
  ++ aiovban-pyaudio.optional-dependencies.cli;

  build-system = [ uv-build ];
  dependencies = [ textual ];
  pyproject = true;

  pythonImportsCheck = [
    "aiovban"
  ];

  passthru.tests = finalAttrs.finalPackage.overrideAttrs (_: {
    doInstallCheck = true;
  });

  meta = {
    inherit (music-assistant.meta) maintainers;
    description = "Asyncio VBAN Protocol Wrapper";
    homepage = "https://github.com/wmbest2/aiovban";
    changelog = "https://github.com/wmbest2/aiovban/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
  };
})
