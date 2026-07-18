{
  lib,
  fetchFromGitLab,
  installShellFiles,
  nixosTests,
  pam,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "please";
  version = "0.5.5";

  src = fetchFromGitLab {
    owner = "edneville";
    repo = "please";
    rev = "v${finalAttrs.version}";
    hash = "sha256-bQ91uCDA2HKuiBmHZ9QP4V6tM6c7hRvECqXzfC6EEnI=";
  };

  patches = [ ./nixos-specific.patch ];
  nativeBuildInputs = [ installShellFiles ];
  buildInputs = [ pam ];
  cargoHash = "sha256-iKRLq2G0XYZFM/k0V6GVtx/Pl4rdfGaD4EVN34FLlOg=";
  # Unit tests are broken on NixOS.
  doCheck = false;

  postInstall = ''
    installManPage man/*
  '';

  passthru.tests = { inherit (nixosTests) please; };

  meta = {
    description = "Polite regex-first sudo alternative";

    longDescription = ''
      Delegate accurate least privilege access with ease. Express easily with a
      regex and expose only what is needed and nothing more. Or validate file
      edits with pleaseedit.

      Please is written with memory safe rust. Traditional C memory unsafety is
      avoided, logic problems may exist but this codebase is relatively small.
    '';

    homepage = "https://www.usenix.org.uk/content/please.html";
    changelog = "https://github.com/edneville/please/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.gpl3Only;
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };
})
