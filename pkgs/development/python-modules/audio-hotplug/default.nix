{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  pyobjc-framework-CoreAudio,
  pytest-asyncio,
  pytestCheckHook,
  pyudev,
  uv-build,
}:

buildPythonPackage (finalAttrs: {
  pname = "audio-hotplug";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "LedFx";
    repo = "audio-hotplug";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Xq81AfJ5E8lAk1JohD7/RlEDVRrbi/ScX80nMiRd+dY=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "uv_build>=0.9.13,<0.10.0" "uv_build"
  '';

  nativeCheckInputs = [
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = [ uv-build ];

  dependencies =
    lib.optionals stdenv.hostPlatform.isLinux [ pyudev ]
    ++ lib.optional stdenv.hostPlatform.isDarwin pyobjc-framework-CoreAudio;

  pyproject = true;
  pythonImportsCheck = [ "audio_hotplug" ];

  meta = {
    description = "Wrapper for Auburns' FastNoise Lite noise generation library";
    homepage = "https://github.com/tizilogic/PyFastNoiseLite";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ SuperSandro2000 ];
  };
})
