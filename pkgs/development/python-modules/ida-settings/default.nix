{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  ida-hcli,
  nix-update-script,
  uv-build,
}:

buildPythonPackage (finalAttrs: {
  pname = "ida-settings";
  version = "3.5.1";

  src = fetchFromGitHub {
    owner = "williballenthin";
    repo = "ida-settings";
    tag = "v${finalAttrs.version}";
    hash = "sha256-InMHWKshBwkx1xrr6yW/K6EmmifUzuRFGJZhwpwVYqc=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "uv_build>=0.8.6,<0.9.0" "uv_build"
  '';

  # Module has no tests
  doCheck = false;
  __structuredAttrs = true;
  build-system = [ uv-build ];
  dependencies = [ ida-hcli ];
  pyproject = true;
  pythonImportsCheck = [ "ida_settings" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Fetch and set configuration values for IDA Plugins";
    homepage = "https://github.com/williballenthin/ida-settings";
    changelog = "https://github.com/williballenthin/ida-settings/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
})
