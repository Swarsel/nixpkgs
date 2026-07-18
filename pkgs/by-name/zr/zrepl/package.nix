{
  lib,
  fetchFromGitHub,
  buildGoModule,
  makeWrapper,
  nixosTests,
  openssh,
  versionCheckHook,
}:
buildGoModule (finalAttrs: {
  pname = "zrepl";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "zrepl";
    repo = "zrepl";
    tag = "v${finalAttrs.version}";
    hash = "sha256-D2ADK1mX6Aq0I2fBeNLZeJ0GdxWxi2ApiZqT4b72yf4=";
  };

  nativeBuildInputs = [
    makeWrapper
  ];

  vendorHash = "sha256-yu/bKkcWhHJSQPU2F4C58RC7geVTVEcXHlV0DRn/sUs=";

  postInstall = ''
    mkdir -p $out/lib/systemd/system
    substitute dist/systemd/zrepl.service $out/lib/systemd/system/zrepl.service \
      --replace /usr/local/bin/zrepl $out/bin/zrepl

    wrapProgram $out/bin/zrepl \
      --prefix PATH : ${lib.makeBinPath [ openssh ]}
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/zrepl/zrepl/internal/version.zreplVersion=${finalAttrs.version}"
  ];

  subPackages = [ "." ];
  versionCheckProgramArg = "version";

  passthru.tests = {
    inherit (nixosTests) zrepl;
  };

  meta = {
    description = "One-stop, integrated solution for ZFS replication";
    homepage = "https://zrepl.github.io/";
    changelog = "https://github.com/zrepl/zrepl/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      cole-h
      mdlayher
    ];

    platforms = lib.platforms.linux;
    mainProgram = "zrepl";
  };
})
