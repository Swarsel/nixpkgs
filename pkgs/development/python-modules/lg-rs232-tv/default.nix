{
  lib,
  fetchFromGitHub,
  aiowebostv,
  buildPythonPackage,
  pytest-asyncio,
  pytest-timeout,
  pytestCheckHook,
  serialx,
  uv-build,
}:

buildPythonPackage (finalAttrs: {
  pname = "lg-rs232-tv";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "home-assistant-libs";
    repo = "lg-rs232-tv";
    tag = finalAttrs.version;
    hash = "sha256-gMjRyZ/gUMAsS0v465ISD38YAlrOB8N/5VAFZkXtyAE=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "uv_build>=0.8.4,<0.9.0" "uv_build"
  '';

  nativeCheckInputs = [
    pytest-asyncio
    pytest-timeout
    pytestCheckHook
  ];

  build-system = [ uv-build ];
  dependencies = [ serialx ];

  optional-dependencies = {
    esphome = serialx.optional-dependencies.esphome;
    remote = [ aiowebostv ];
  };

  pyproject = true;
  pythonImportsCheck = [ "lg_rs232_tv" ];

  meta = {
    description = "Async library to control LG TVs over RS232";
    homepage = "https://github.com/home-assistant-libs/lg-rs232-tv";
    changelog = "https://github.com/home-assistant-libs/lg-rs232-tv/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.jamiemagee ];
  };
})
