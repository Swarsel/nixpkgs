{
  lib,
  fetchFromGitHub,
  installShellFiles,
  kubectl,
  makeWrapper,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "kubie";
  version = "0.26.1";

  src = fetchFromGitHub {
    owner = "kubie-org";
    repo = "kubie";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-eSzNCH0MiGvLKHrSXFSXQq4lN5tfmr0NcuGaN96Invs=";
  };

  nativeBuildInputs = [
    installShellFiles
    makeWrapper
  ];

  cargoHash = "sha256-nXzIXMpCtibTN4rsPQFtSSjCQzylWWQZixwbH680ue0=";

  postInstall = ''
    installShellCompletion completion/kubie.{bash,fish}

    wrapProgram "$out/bin/kubie" \
      --prefix PATH : "${
        lib.makeBinPath [
          kubectl
        ]
      }"
  '';

  buildNoDefaultFeatures = true;

  meta = {
    description = "Shell independent context and namespace switcher for kubectl";
    homepage = "https://github.com/kubie-org/kubie";
    license = with lib.licenses; [ zlib ];
    maintainers = with lib.maintainers; [ illiusdope ];
    mainProgram = "kubie";
  };
})
