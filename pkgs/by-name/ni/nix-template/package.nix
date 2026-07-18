{
  lib,
  stdenv,
  fetchFromGitHub,
  installShellFiles,
  makeWrapper,
  nix,
  openssl,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "nix-template";
  version = "0.4.1";

  src = fetchFromGitHub {
    owner = "jonringer";
    repo = "nix-template";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-42u5FmTIKHpfQ2zZQXIrFkAN2/XvU0wWnCRrQkQzcNI=";
    name = "${finalAttrs.pname}-${finalAttrs.version}-src";
  };

  nativeBuildInputs = [
    installShellFiles
    makeWrapper
    pkg-config
  ];

  buildInputs = [ openssl ];
  cargoHash = "sha256-cLSGWOyBQLv235TeYqSVg/f0Zmcnpj+RshINN69JYEU=";

  # needed for nix-prefetch-url
  postInstall = ''
    wrapProgram $out/bin/nix-template \
      --prefix PATH : ${lib.makeBinPath [ nix ]}

  ''
  + lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd nix-template \
      --bash <($out/bin/nix-template completions bash) \
      --fish <($out/bin/nix-template completions fish) \
      --zsh <($out/bin/nix-template completions zsh)
  '';

  meta = {
    description = "Make creating nix expressions easy";
    homepage = "https://github.com/jonringer/nix-template/";
    changelog = "https://github.com/jonringer/nix-template/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.cc0;
    maintainers = [ ];
    mainProgram = "nix-template";
  };
})
