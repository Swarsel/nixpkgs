{
  lib,
  fetchFromGitHub,
  buildGoModule,
  go-mockery,
  versionCheckHook,
  writableTmpDirAsHomeHook,
}:
buildGoModule (finalAttrs: {
  pname = "sesh";
  version = "2.27.0";

  src = fetchFromGitHub {
    owner = "joshmedeski";
    repo = "sesh";
    tag = "v${finalAttrs.version}";
    hash = "sha256-py4Dok8nyyxqenaY5Clhik0W8vo3dsw2EhzUZxQtA38=";
  };

  nativeBuildInputs = [
    go-mockery
    writableTmpDirAsHomeHook
  ];

  vendorHash = "sha256-9IiDp/HaxXQAyNzuVBLiO+oIijBbdKBjssCmj8WV9V4=";

  preBuild = ''
    mockery
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  __structuredAttrs = true;

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${finalAttrs.version}"
  ];

  # NOTE: prevent crash when getting vendor deps/hash
  overrideModAttrs = _: {
    preBuild = "";
  };

  versionCheckKeepEnvironment = [ "HOME" ];

  meta = {
    description = "Smart session manager for the terminal";
    homepage = "https://github.com/joshmedeski/sesh";
    changelog = "https://github.com/joshmedeski/sesh/releases/tag/${finalAttrs.src.rev}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      gwg313
      randomdude
      t-monaghan
    ];

    mainProgram = "sesh";
  };
})
