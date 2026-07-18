{
  lib,
  stdenv,
  fetchFromGitHub,
  installShellFiles,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "desk-exec";
  version = "1.0.2";

  src = fetchFromGitHub {
    owner = "AxerTheAxe";
    repo = "desk-exec";
    tag = "v${finalAttrs.version}";
    hash = "sha256-bJLdd07IAf+ba++vtS0iSmeQSGygwSVNry2bHTDAgjE=";
  };

  nativeBuildInputs = [ installShellFiles ];
  cargoHash = "sha256-lwc+zth4qCynErG3ldUnu/lX4NfZfxn+XDzJA/kp7S4=";

  postInstall = ''
    pushd target/${stdenv.hostPlatform.config}/release/dist
      installShellCompletion desk-exec.{bash,fish}
      installShellCompletion _desk-exec
      installManPage desk-exec.1
    popd
  '';

  meta = {
    description = "Execute programs defined in XDG desktop entries directly from the command line";
    homepage = "https://github.com/AxerTheAxe/desk-exec";
    license = lib.licenses.unlicense;
    maintainers = [ lib.maintainers.axertheaxe ];
    platforms = lib.platforms.linux;
    mainProgram = "desk-exec";
  };
})
