{
  lib,
  stdenv,
  fetchFromGitHub,
  pandoc,
  python3Packages,
}:

let
  pythonPackages = python3Packages.overrideScope (
    self: super: {
      lsprotocol = self.lsprotocol_2023;
      pygls = self.pygls_1;
    }
  );
in
pythonPackages.buildPythonApplication (finalAttrs: {
  pname = "systemd-language-server";
  version = "0.3.5";

  src = fetchFromGitHub {
    owner = "psacawa";
    repo = "systemd-language-server";
    tag = finalAttrs.version;
    hash = "sha256-QRd2mV4qRh4OfVJ2/5cOm3Wh8ydsLTG9Twp346DHjs0=";
  };

  nativeCheckInputs = [
    pandoc
    pythonPackages.pytestCheckHook
  ];

  __darwinAllowLocalNetworking = true;

  build-system = with pythonPackages; [
    poetry-core
  ];

  dependencies = with pythonPackages; [
    lxml
    pygls
  ];

  disabledTests = lib.optionals stdenv.hostPlatform.isDarwin [
    # TimeoutError
    "test_hover"
  ];

  pyproject = true;
  pythonImportsCheck = [ "systemd_language_server" ];

  pythonRelaxDeps = [
    "lxml"
  ];

  meta = {
    description = "Language Server for Systemd unit files";
    homepage = "https://github.com/psacawa/systemd-language-server";
    changelog = "https://github.com/psacawa/systemd-language-server/releases/tag/${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ GaetanLepage ];
    mainProgram = "systemd-language-server";
  };
})
