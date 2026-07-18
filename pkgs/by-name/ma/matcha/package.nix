{
  lib,
  stdenv,
  fetchFromGitHub,
  apple-sdk_15,
  buildGoLatestModule,
  nix-update-script,
  pcsclite,
  pkg-config,
  versionCheckHook,
}:

buildGoLatestModule (finalAttrs: {
  pname = "matcha";
  version = "0.43.0";

  src = fetchFromGitHub {
    owner = "floatpane";
    repo = "matcha";
    tag = "v${finalAttrs.version}";
    hash = "sha256-x+k1/k7pwJ0MW0t31ieaOkbP8LtqDSmHOBrNEGA0K6Q=";
  };

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    pkg-config
  ];

  buildInputs =
    lib.optionals stdenv.hostPlatform.isLinux [ pcsclite ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [ apple-sdk_15 ];

  vendorHash = "sha256-5smWIw8ofG61ugHxFbmQ9r9vcxi098/UmxUE15lx4wE=";
  env.CGO_ENABLED = 1;
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  __structuredAttrs = true;

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${finalAttrs.version}"
    "-X main.date=1970-01-01T00:00:00Z"
  ];

  proxyVendor = true;
  subPackages = [ "." ];
  versionCheckProgramArg = "--version";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Beautiful and functional email client for the terminal";
    homepage = "https://matcha.email";
    changelog = "https://github.com/floatpane/matcha/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ andrinoff ];
    platforms = lib.platforms.darwin ++ lib.platforms.linux;
    mainProgram = "matcha";
  };
})
