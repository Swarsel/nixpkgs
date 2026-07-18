{
  lib,
  fetchFromGitHub,
  installShellFiles,
  nix-update-script,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "fsel";
  version = "3.1.0";

  src = fetchFromGitHub {
    owner = "Mjoyufull";
    repo = "fsel";
    tag = finalAttrs.version;
    hash = "sha256-h8CA2ZR/XKQJDq5uopOD1I+ZpWehuVNiJLeuuLaKAQA=";
  };

  nativeBuildInputs = [
    installShellFiles
    pkg-config
  ];

  cargoHash = "sha256-RHDTdwbsKQtz8Pwq3pNgoUvK8y5NO94zVhsKiBVET+I=";

  postInstall = ''
    installManPage fsel.1
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Fast TUI app launcher and fuzzy finder for GNU/Linux and *BSD";
    homepage = "https://github.com/Mjoyufull/fsel";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ nettika ];
    platforms = with lib.platforms; linux ++ freebsd ++ openbsd ++ netbsd;
    mainProgram = "fsel";
  };
})
