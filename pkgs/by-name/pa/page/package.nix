{
  lib,
  fetchFromGitHub,
  fetchpatch,
  installShellFiles,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "page";
  version = "4.6.3";

  src = fetchFromGitHub {
    owner = "I60R";
    repo = "page";
    rev = "v${finalAttrs.version}";
    hash = "sha256-uNdtgx9/9+KOfQvHiKNrT8NFWtR2tfJuI2bMwywBC/4=";
  };

  nativeBuildInputs = [ installShellFiles ];
  cargoHash = "sha256-ZoLYnXU1y+7AcbxUlcY9MPGZuuxzG8d5Im2/uSlCoaw=";

  postInstall = ''
    completions_dir=$(find "target" -name "assets" -type d -printf "%T+\t%p\n" | sort | awk 'NR==1{print $2}')
    installShellCompletion --bash $completions_dir/page.bash
    installShellCompletion --fish $completions_dir/page.fish
    installShellCompletion --zsh $completions_dir/_page
  '';

  cargoPatches = [
    # Cargo.lock is outdated.
    # https://github.com/I60R/page/pull/45.
    (fetchpatch {
      hash = "sha256-qA5oP4K/6eG0A+syVNb1izl+bnYll5V6sWM3LVFTb4o=";
      url = "https://github.com/I60R/page/commit/83f936b64620ba74043c1db31207b4366c0f7e3d.patch";
    })
  ];

  meta = {
    description = "Use neovim as pager";
    homepage = "https://github.com/I60R/page";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.s1341 ];
    mainProgram = "page";
  };
})
