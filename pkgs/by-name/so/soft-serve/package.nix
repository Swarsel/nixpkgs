{
  lib,
  fetchFromGitHub,
  bash,
  buildGoModule,
  git,
  makeWrapper,
  nixosTests,
}:

buildGoModule (finalAttrs: {
  pname = "soft-serve";
  version = "0.11.6";

  src = fetchFromGitHub {
    owner = "charmbracelet";
    repo = "soft-serve";
    tag = "v${finalAttrs.version}";
    hash = "sha256-oWZfhB14Yjj3/BKKhowKDKX5v4RvIwjHDCSFfnI+f54=";
  };

  nativeBuildInputs = [ makeWrapper ];
  vendorHash = "sha256-nsrfohr2b6zpbhWVRfOPydCpyUZzbR3YJz5viWGUwmQ=";
  doCheck = false;

  postInstall = ''
    # Soft-serve generates git-hooks at run-time.
    # The scripts require git and bash inside the path.
    wrapProgram $out/bin/soft \
      --prefix PATH : "${
        lib.makeBinPath [
          git
          bash
        ]
      }"
  '';

  ldflags = [
    "-s"
    "-w"
    "-X=main.Version=${finalAttrs.version}"
  ];

  passthru.tests = nixosTests.soft-serve;

  meta = {
    description = "Tasty, self-hosted Git server for the command line";
    homepage = "https://github.com/charmbracelet/soft-serve";
    changelog = "https://github.com/charmbracelet/soft-serve/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ miniharinn ];
    mainProgram = "soft";
  };
})
