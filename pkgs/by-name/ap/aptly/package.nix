{
  lib,
  fetchFromGitHub,
  aptly,
  buildGoModule,
  bzip2,
  gnupg,
  graphviz,
  installShellFiles,
  makeWrapper,
  testers,
  xz,
}:

buildGoModule (finalAttrs: {
  pname = "aptly";
  version = "1.6.3";

  src = fetchFromGitHub {
    owner = "aptly-dev";
    repo = "aptly";
    tag = "v${finalAttrs.version}";
    hash = "sha256-fjNN8EffY9G8YX/uME5ehs2zZj/YRA62y/muqigWSnE=";
  };

  nativeBuildInputs = [
    installShellFiles
    makeWrapper
  ];

  vendorHash = "sha256-QPYKdiEiV1iS3xJ3A66ILUXAlj0TGXuGf11wzdX3Z7Y=";

  preBuild = ''
    echo ${finalAttrs.version} > VERSION
  '';

  doCheck = false;

  postInstall = ''
    installShellCompletion --bash --name aptly completion.d/aptly
    installShellCompletion --zsh --name _aptly completion.d/_aptly
    wrapProgram $out/bin/aptly \
      --prefix PATH : ${
        lib.makeBinPath [
          gnupg
          bzip2
          xz
          graphviz
        ]
      }
  '';

  excludedPackages = [
    "system"
  ];

  ldflags = [
    "-s"
    "-w"
  ];

  passthru.tests.version = testers.testVersion {
    command = "aptly version";
    package = aptly;
  };

  meta = {
    description = "Debian repository management tool";
    homepage = "https://www.aptly.info";
    changelog = "https://github.com/aptly-dev/aptly/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      cdepillabout
      montag451
      wraithm
    ];

    mainProgram = "aptly";
  };
})
