{
  lib,
  fetchFromSourcehut,
  installShellFiles,
  nix-update-script,
  pam,
  rustPlatform,
  scdoc,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "greetd";
  version = "0.10.3";

  src = fetchFromSourcehut {
    owner = "~kennylevinsen";
    repo = "greetd";
    rev = finalAttrs.version;
    hash = "sha256-jgvYnjt7j4uubpBxrYM3YiUfF1PWuHAN1kwnv6Y+bMg=";
  };

  nativeBuildInputs = [
    scdoc
    installShellFiles
  ];

  buildInputs = [
    pam
  ];

  cargoHash = "sha256-JwTLZawY9+M09IDbMPoNUcNrnW1C2OVlEVn1n7ol6dY=";

  postInstall = ''
    for f in man/*; do
      scdoc < "$f" > "$(sed 's/-\([0-9]\)\.scd$/.\1/' <<< "$f")"
      rm "$f"
    done
    installManPage man/*
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Minimal and flexible login manager daemon";

    longDescription = ''
      greetd is a minimal and flexible login manager daemon
      that makes no assumptions about what you want to launch.
      Comes with agreety, a simple, text-based greeter.
    '';

    homepage = "https://sr.ht/~kennylevinsen/greetd/";
    license = lib.licenses.gpl3Only;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "greetd";
  };
})
