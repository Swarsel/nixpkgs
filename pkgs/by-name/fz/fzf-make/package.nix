{
  lib,
  fetchFromGitHub,
  bat,
  gnugrep,
  gnumake,
  makeBinaryWrapper,
  runtimeShell,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "fzf-make";
  version = "0.69.0";

  src = fetchFromGitHub {
    owner = "kyu08";
    repo = "fzf-make";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ezE7plWdPqfENprOWhl5YQnoXk9khXsDtsYf6Lifk3w=";
  };

  nativeBuildInputs = [ makeBinaryWrapper ];
  cargoHash = "sha256-uF+oV0ZvGsRy20DkNrVowyb+RoYVtYN4R/gOZ6WzHQw=";

  postInstall = ''
    wrapProgram $out/bin/fzf-make \
      --set SHELL ${runtimeShell} \
      --suffix PATH : ${
        lib.makeBinPath [
          bat
          gnugrep
          gnumake
        ]
      }
  '';

  meta = {
    inherit (finalAttrs.src.meta) homepage;
    description = "Fuzzy finder for Makefile";
    changelog = "https://github.com/kyu08/fzf-make/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      sigmanificient
    ];

    mainProgram = "fzf-make";
  };
})
