{
  lib,
  stdenv,
  fetchFromGitHub,
  apple-sdk,
  libgit2,
  libiconv,
  pkg-config,
  rustPlatform,
  versionCheckHook,
  zlib,
  withGit ? true,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "jj-starship";
  version = "0.7.1";

  src = fetchFromGitHub {
    owner = "dmmulroy";
    repo = "jj-starship";
    tag = "v${finalAttrs.version}";
    hash = "sha256-NLds7i1ZmscicaNLmkZCWmc7A+367BXxGioRd4yYof8=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    zlib
  ]
  ++ lib.optionals withGit [ libgit2 ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    apple-sdk
    libiconv
  ];

  cargoHash = "sha256-i7x/y+BkKH+Xj1bU4RRe9fcteabB+4uAgJuW3x5/jv4=";
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  buildNoDefaultFeatures = !withGit;

  meta = {
    description = "Unified Starship prompt module for Git and Jujutsu repositories that is optimized for latency";
    homepage = "https://github.com/dmmulroy/jj-starship";
    changelog = "https://github.com/dmmulroy/jj-starship/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ drupol ];
    mainProgram = "jj-starship";
  };
})
