{
  lib,
  stdenv,
  fetchFromGitHub,
  gtk3,
  openssl,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "effitask";
  version = "1.4.2";

  src = fetchFromGitHub {
    owner = "todotxt-rs";
    repo = "effitask";
    rev = finalAttrs.version;
    sha256 = "sha256-6BA/TCCqVh5rtgGkUgk8nIqUzozipC5rrkbXMDWYpdQ=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    openssl
    gtk3
  ];

  cargoHash = "sha256-j9WCzsh6aitmJeeyLDm0YrZHEAZlCNfGWANM/nmuncw=";

  # default installPhase don't install assets
  installPhase = ''
    runHook preInstall
    make install PREFIX="$out" TARGET="target/${stdenv.hostPlatform.rust.rustcTarget}/release/effitask"
    runHook postInstall
  '';

  meta = {
    description = "Graphical task manager, based on the todo.txt format";

    longDescription = ''
      To use it as todo.sh add-on, create a symlink like this:
      mkdir ~/.todo.actions.d/
      ln -s $(which effitask) ~/.todo.actions.d/et

      Or use it as standalone program by defining some environment variables
      like described in the projects readme.
    '';

    homepage = "https://github.com/todotxt-rs/effitask";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ davidak ];
    mainProgram = "effitask";
  };
})
