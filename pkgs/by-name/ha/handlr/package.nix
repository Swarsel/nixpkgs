{
  lib,
  stdenv,
  fetchFromGitHub,
  installShellFiles,
  libiconv,
  rustPlatform,
  shared-mime-info,
}:

rustPlatform.buildRustPackage {
  pname = "handlr";
  version = "unstable-2021-08-29";

  src = fetchFromGitHub {
    owner = "chmln";
    repo = "handlr";
    rev = "90e78ba92d0355cb523abf268858f3123fd81238";
    sha256 = "sha256-wENhlUBwfNg/r7yMKa1cQI1fbFw+qowwK8EdO912Yys=";
  };

  nativeBuildInputs = [
    installShellFiles
    shared-mime-info
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isDarwin [ libiconv ];
  cargoHash = "sha256-/Kk2vuFkgtHarLrjqc5PkRZL2pV1Y7Gb02mWwtaVpDI=";

  preCheck = ''
    export HOME=$TEMPDIR
  '';

  postInstall = ''
    installShellCompletion \
      --zsh  completions/_handlr \
      --bash  completions/handlr \
      --fish completions/handlr.fish
  '';

  meta = {
    description = "Alternative to xdg-open to manage default applications with ease";
    homepage = "https://github.com/chmln/handlr";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ artturin ];
    mainProgram = "handlr";
  };
}
