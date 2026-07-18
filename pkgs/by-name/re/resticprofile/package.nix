{
  lib,
  fetchFromGitHub,
  bash,
  buildGoModule,
  installShellFiles,
  restic,
  resticprofile,
  testers,
}:

buildGoModule (finalAttrs: {
  pname = "resticprofile";
  version = "0.31.0";

  src = fetchFromGitHub {
    owner = "creativeprojects";
    repo = "resticprofile";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ezelvyroQG1EW3SU63OVHJ/T4qjN5DRllvPIXnei1Z4=";
  };

  postPatch = ''
    substituteInPlace schedule_jobs.go \
        --replace-fail "os.Executable()" "\"$out/bin/resticprofile\", nil"

    substituteInPlace shell/command.go \
        --replace-fail '"bash"' '"${lib.getExe bash}"'

    substituteInPlace filesearch/filesearch.go \
        --replace-fail 'paths := getSearchBinaryLocations()' 'return "${lib.getExe restic}", nil; paths := getSearchBinaryLocations()'

  '';

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-M9S6F/Csz7HnOq8PSWjpENKm1704kVx9zDts1ieraTE=";

  preCheck = ''
    rm batt/battery_test.go # tries to get battery data
    rm commands_test.go # tries to use systemctl
    rm config/path_test.go # expects normal environment
    rm lock/lock_test.go # needs ping
    rm preventsleep/caffeinate_test.go # tries to communicate with dbus
    rm priority/ioprio_test.go # tries to set nice(2) IO priority
    rm restic/downloader_test.go # tries to use network
    rm schedule/*_test.go # tries to use systemctl
    rm update_test.go # tries to use network
    rm user/user_test.go # expects normal environment
    rm util/tempdir_test.go # expects normal environment
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 $GOPATH/bin/resticprofile -t $out/bin

    installShellCompletion --cmd resticprofile \
        --bash <($out/bin/resticprofile generate --bash-completion) \
        --zsh <($out/bin/resticprofile generate --zsh-completion)

    runHook postInstall
  '';

  ldflags = [
    "-X main.version=${finalAttrs.version}"
    "-X main.commit=${finalAttrs.src.rev}"
    "-X main.date=unknown"
    "-X main.builtBy=nixpkgs"
  ];

  passthru = {
    tests.version = testers.testVersion {
      command = "resticprofile version";
      package = resticprofile;
    };
  };

  meta = {
    description = "Configuration profiles manager for restic backup";
    homepage = "https://creativeprojects.github.io/resticprofile/";
    changelog = "https://github.com/creativeprojects/resticprofile/releases/tag/v${finalAttrs.version}";

    license = with lib.licenses; [
      gpl3Only
      lgpl3 # bash shell completion
    ];

    maintainers = with lib.maintainers; [ tomasajt ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "resticprofile";
  };
})
