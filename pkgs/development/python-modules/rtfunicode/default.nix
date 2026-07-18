{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  unittestCheckHook,
  uv-build,
}:

buildPythonPackage (finalAttrs: {
  pname = "rtfunicode";
  version = "2.3";

  src = fetchFromGitHub {
    owner = "mjpieters";
    repo = "rtfunicode";
    tag = "v${finalAttrs.version}";
    hash = "sha256-dmPpMplCQIJMHhNFzOIjKwEHVio2mjFEbDmq1Y9UJkA=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "uv_build>=0.9.26,<0.10.0" "uv_build"
  '';

  nativeBuildInputs = [ unittestCheckHook ];
  build-system = [ uv-build ];
  pyproject = true;
  pythonImportsCheck = [ "rtfunicode" ];

  meta = {
    description = "Encoder for unicode to RTF 1.5 command sequences";
    homepage = "https://github.com/mjpieters/rtfunicode";
    changelog = "https://github.com/mjpieters/rtfunicode/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.bsd2;
    maintainers = [ ];
  };
})
