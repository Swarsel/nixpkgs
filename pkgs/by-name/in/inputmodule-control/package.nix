{
  lib,
  stdenv,
  fetchFromGitHub,
  inputmodule-control,
  libudev-zero,
  pkg-config,
  rustPlatform,
  testers,
  udevCheckHook,
}:

rustPlatform.buildRustPackage rec {
  pname = "inputmodule-control";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "FrameworkComputer";
    repo = "inputmodule-rs";
    rev = "v${version}";
    hash = "sha256-5sqTkaGqmKDDH7byDZ84rzB3FTu9AKsWxA6EIvUrLCU=";
  };

  nativeBuildInputs = [
    pkg-config
    udevCheckHook
  ];

  buildInputs = [ libudev-zero ];
  cargoHash = "sha256-s5k23p0Fo+DQvGpDvy/VmGNFK7ZysqLIyDPuUn6n724=";

  postInstall = ''
    install -Dm644 release/50-framework-inputmodule.rules $out/etc/udev/rules.d/50-framework-inputmodule.rules
  '';

  doInstallCheck = true;
  buildAndTestSubdir = "inputmodule-control";

  passthru.tests.version = testers.testVersion {
    package = inputmodule-control;
  };

  meta = {
    description = "CLI tool to control Framework input modules like the LED matrix";
    homepage = "https://github.com/FrameworkComputer/inputmodule-rs";
    changelog = "https://github.com/FrameworkComputer/inputmodule-rs/releases/tag/${src.rev}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ Kitt3120 ];
    platforms = lib.platforms.linux;
    mainProgram = "inputmodule-control";
    downloadPage = "https://github.com/FrameworkComputer/inputmodule-rs/releases/tag/${src.rev}";
  };
}
