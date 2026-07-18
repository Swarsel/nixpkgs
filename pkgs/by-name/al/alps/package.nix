{
  lib,
  fetchFromGitHub,
  buildGoModule,
  buildNpmPackage,
  nixosTests,
  util-linux,
  versionCheckHook,
}:
buildGoModule (finalAttrs: {
  pname = "alps";
  version = "1";

  src = fetchFromGitHub {
    owner = "migadu";
    repo = "alps";
    tag = "v${finalAttrs.version}";
    hash = "sha256-uzr0N50qKpIoOr7YFfuhnJ/CTaMvcP7TZujM5YpklMs=";
  };

  postPatch = ''
    substituteInPlace dist/alps.service \
      --replace-fail /usr/local/bin "$out/bin" \
      --replace-fail /bin/kill "${lib.getExe' util-linux "kill"}"

    rm -r frontend/dist
    cp -r ${finalAttrs.passthru.frontend} frontend/dist
  '';

  vendorHash = "sha256-Nm9TC0j/PSraO1AtxUJmFQWdhdLzeLP0CXY0FZZ6pV8=";

  postInstall = ''
    install -Dm644 -t "$out/lib/systemd/system/" dist/alps.service
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  __structuredAttrs = true;

  ldflags = [
    "-s"
    "-X main.version=${finalAttrs.version}"
  ];

  subPackages = [ "cmd/alps" ];
  versionCheckProgramArg = "-version";

  passthru = {
    frontend = buildNpmPackage (finalAttrs': {
      inherit (finalAttrs) version src;
      pname = "${finalAttrs.pname}-frontend";

      postPatch = ''
        rm -r dist
      '';

      npmDepsHash = "sha256-gR9leLQSPo/qBNf6Yy1b2klawwuhKIvofCSPYkHOJKk=";

      installPhase = ''
        runHook preInstall

        mkdir -p "$out"
        cp -r dist/. "$out"

        runHook postInstall
      '';

      sourceRoot = "${finalAttrs'.src.name}/frontend";
    });

    tests = { inherit (nixosTests) alps; };
  };

  meta = {
    description = "Simple and extensible webmail";
    homepage = "https://github.com/migadu/alps";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      booklearner
      madonius
      hmenke
      prince213
    ];

    mainProgram = "alps";
    downloadPage = "https://github.com/migadu/alps/releases";
    teams = with lib.teams; [ ngi ];
  };
})
