{
  lib,
  fetchFromCodeberg,
  imagemagick,
  installShellFiles,
  makeWrapper,
  nix-update-script,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "wallust";
  version = "3.5.2";

  src = fetchFromCodeberg {
    owner = "explosion-mental";
    repo = "wallust";
    rev = finalAttrs.version;
    hash = "sha256-ZgkeM9gMw9TB5NR+xyxBepKHO16bLVVFJN4IY39gllg=";
  };

  nativeBuildInputs = [
    makeWrapper
    installShellFiles
  ];

  cargoHash = "sha256-XrIi+8p2OZ7O6MTgqKbgN/9gLUbvB7uN9Yr2X1BYHIU=";

  postInstall = ''
    installManPage man/wallust*
    installShellCompletion --cmd wallust \
      --bash completions/wallust.bash \
      --zsh completions/_wallust \
      --fish completions/wallust.fish
  '';

  postFixup = ''
    wrapProgram $out/bin/wallust \
      --prefix PATH : "${lib.makeBinPath [ imagemagick ]}"
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Better pywal";
    homepage = "https://codeberg.org/explosion-mental/wallust";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      onemoresuza
      iynaix
    ];

    mainProgram = "wallust";
    downloadPage = "https://codeberg.org/explosion-mental/wallust/releases/tag/${finalAttrs.version}";
  };
})
