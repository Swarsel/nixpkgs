{
  lib,
  fetchFromSourcehut,
  # Script dependencies.
  fzf,
  installShellFiles,
  makeWrapper,
  nix-update-script,
  rustPlatform,
  scdoc,
  wl-clipboard,
  xclip,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "license-cli";
  version = "3.2.1";

  src = fetchFromSourcehut {
    owner = "~zethra";
    repo = "license";
    rev = finalAttrs.version;
    hash = "sha256-eS4KuoUJA6e+Y6WNFCJTXgjV5t3Eh7wc2KvWi/+jCeI=";
  };

  nativeBuildInputs = [
    installShellFiles
    makeWrapper
  ];

  cargoHash = "sha256-7C/KAMBXbkxsjnkIJsGBOasOGGIXV8QhVEkkP+vseos=";

  preInstall = ''
    ${scdoc}/bin/scdoc < doc/license.scd > license.1
  '';

  postInstall = ''
    installShellCompletion completions/license.{bash,fish}
    installShellCompletion --zsh completions/_license
    installManPage ./license.1

    install -Dm0755 ./scripts/set-license -t $out/bin
    wrapProgram $out/bin/set-license \
      --prefix PATH : "$out/bin" \
      --prefix PATH : ${lib.makeBinPath [ fzf ]}

    install -Dm0755 ./scripts/copy-header -t $out/bin
    wrapProgram $out/bin/copy-header \
      --prefix PATH : "$out/bin" \
      --prefix PATH : ${
        lib.makeBinPath [
          wl-clipboard
          xclip
        ]
      }
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Command-line tool to easily add license to your project";
    homepage = "https://git.sr.ht/~zethra/license";
    license = lib.licenses.mpl20;
    maintainers = [ ];
    mainProgram = "license";
  };
})
