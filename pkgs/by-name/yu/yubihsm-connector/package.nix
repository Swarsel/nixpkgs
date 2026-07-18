{
  lib,
  fetchFromGitHub,
  buildGoModule,
  libusb1,
  pkg-config,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "yubihsm-connector";
  version = "3.0.7";

  src = fetchFromGitHub {
    owner = "Yubico";
    repo = "yubihsm-connector";
    rev = finalAttrs.version;
    hash = "sha256-ddf8IamX8wC8IG9puFDoSKsVqc9KE/LtsJ0Wk0FFquw=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    libusb1
  ];

  vendorHash = "sha256-vtIXFOptDbBKjnDUSD9ng5tnfYQ3lklwgcEUvKMdCOM=";

  preBuild = ''
    GOOS= GOARCH= go generate
  '';

  doInstallCheck = true;
  installCheckInputs = [ versionCheckHook ];

  ldflags = [
    "-s"
    "-w"
  ];

  # Don't run go generate in the module fetching
  overrideModAttrs = _: {
    preBuild = null;
  };

  versionCheckProgramArg = "version";

  meta = {
    description = "Performs the communication between the YubiHSM 2 and applications that use it";
    homepage = "https://developers.yubico.com/yubihsm-connector/";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      matthewcroughan
      numinit
    ];

    mainProgram = "yubihsm-connector";
  };
})
