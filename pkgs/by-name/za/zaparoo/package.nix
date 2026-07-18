{
  lib,
  fetchurl,
  fetchFromGitHub,
  buildGoModule,
  libnfc,
  libusb1,
  nix-update-script,
  pkg-config,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "zaparoo";
  version = "2.5.1";

  src = fetchFromGitHub {
    owner = "ZaparooProject";
    repo = "zaparoo-core";
    tag = "v${finalAttrs.version}";
    hash = "sha256-U/MNK8K7XAEuIa06mjJdUJRKHUFWqH7BFhAgJCbdj/s=";
  };

  postPatch = ''
    mkdir -p pkg/assets/_app/dist
    tar xf ${finalAttrs.webUI} -C pkg/assets/_app/dist/
  '';

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    libusb1
    libnfc
  ];

  vendorHash = "sha256-UTMYZ8la4VsxIVjcRg8l1yGy52CRjv/6WZQgHJ+oFdE=";
  env.CGO_ENABLED = 1;

  postInstall = ''
    mv $out/bin/linux $out/bin/zaparoo
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  ldflags = [
    "-s"
    "-X github.com/ZaparooProject/zaparoo-core/pkg/config.AppVersion=${finalAttrs.version}"
  ];

  subPackages = [ "cmd/linux" ];

  tags = [
    "netgo"
    "osusergo"
    "sqlite_omit_load_extension"
  ];

  webUI = fetchurl {
    hash = "sha256-77QyMFbx73vaKIRDCnhdqDXBb8MfQSsCWghe3XEL0tk=";
    url = "https://github.com/ZaparooProject/zaparoo-app/releases/download/v${finalAttrs.webUIVersion}/zaparoo_app-web-${finalAttrs.webUIVersion}.tar.gz";
  };

  webUIVersion = "1.8.0";

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Launch games and cores on your MiSTer, emulators and handhelds using NFC tags or cards";
    homepage = "https://zaparoo.org/";
    changelog = "https://github.com/ZaparooProject/zaparoo-core/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ liberodark ];
    mainProgram = "zaparoo";
  };
})
