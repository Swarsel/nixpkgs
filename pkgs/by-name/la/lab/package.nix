{
  lib,
  fetchFromGitHub,
  buildGoModule,
  git,
  installShellFiles,
  makeBinaryWrapper,
  xdg-utils,
}:

buildGoModule (finalAttrs: {
  pname = "lab";
  version = "0.25.1";

  src = fetchFromGitHub {
    owner = "zaquestion";
    repo = "lab";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-VCvjP/bSd/0ywvNWPsseXn/SPkdp+BsXc/jTvB11EOk=";
  };

  nativeBuildInputs = [
    makeBinaryWrapper
    installShellFiles
  ];

  vendorHash = "sha256-ChysquNuUffcM3qaWUdqu3Av33gnKkdlotEoFKoedA0=";
  doCheck = false;

  postInstall = ''
    # create shell completions before wrapProgram so that lab detects the right path for itself
    installShellCompletion --cmd lab \
      --bash <($out/bin/lab completion bash) \
      --fish <($out/bin/lab completion fish) \
      --zsh <($out/bin/lab completion zsh)
    # make xdg-open overrideable at runtime
    wrapProgram $out/bin/lab \
      --suffix PATH ":" "${
        lib.makeBinPath [
          git
          xdg-utils
        ]
      }"
  '';

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${finalAttrs.version}"
  ];

  subPackages = [ "." ];

  meta = {
    description = "Wraps Git or Hub, making it simple to clone, fork, and interact with repositories on GitLab";
    homepage = "https://zaquestion.github.io/lab";
    license = lib.licenses.cc0;
    maintainers = [ ];
    mainProgram = "lab";
  };
})
