{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPackages,
  installShellFiles,
  libgit2,
  makeBinaryWrapper,
  nix-update-script,
  pkg-config,
  rustPlatform,
  versionCheckHook,
  zlib,
  withClipboard ? true,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "broot";
  version = "1.57.0";

  src = fetchFromGitHub {
    owner = "Canop";
    repo = "broot";
    tag = "v${finalAttrs.version}";
    hash = "sha256-uRMa8zaXXM8KWUplYMyOLic/WITLU0eAbZ2VDgM/PBw=";
  };

  postPatch = ''
    # Fill the version stub in the man page. We can't fill the date
    # stub reproducibly.
    substitute man/page man/broot.1 \
      --replace-fail "#version" "${finalAttrs.version}"
  '';

  nativeBuildInputs = [
    installShellFiles
    makeBinaryWrapper
    pkg-config
  ];

  buildInputs = [ libgit2 ] ++ lib.optionals stdenv.hostPlatform.isDarwin [ zlib ];
  cargoHash = "sha256-p4R8+PcRmjy/2q7lpfUevuYROPrCQEffmXx5vRrjwKs=";
  env.RUSTONIG_SYSTEM_LIBONIG = true;

  postInstall =
    lib.optionalString (stdenv.hostPlatform.emulatorAvailable buildPackages) ''
      # Install shell function for bash.
      ${stdenv.hostPlatform.emulator buildPackages} $out/bin/broot --print-shell-function bash > br.bash
      install -Dm0444 -t $out/etc/profile.d br.bash

      # Install shell function for zsh.
      ${stdenv.hostPlatform.emulator buildPackages} $out/bin/broot --print-shell-function zsh > br.zsh
      install -Dm0444 br.zsh $out/share/zsh/site-functions/br

      # Install shell function for fish
      ${stdenv.hostPlatform.emulator buildPackages} $out/bin/broot --print-shell-function fish > br.fish
      install -Dm0444 -t $out/share/fish/vendor_functions.d br.fish

    ''
    + ''
      # install shell completion files
      OUT_DIR=$releaseDir/build/broot-*/out

      installShellCompletion --bash $OUT_DIR/{br,broot}.bash
      installShellCompletion --fish $OUT_DIR/{br,broot}.fish
      installShellCompletion --zsh $OUT_DIR/{_br,_broot}

      installManPage man/broot.1

      # Do not nag users about installing shell integration, since
      # it is impure.
      wrapProgram $out/bin/broot \
        --set BR_INSTALL no
    '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  buildFeatures = lib.optionals withClipboard [ "clipboard" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Interactive tree view, a fuzzy search, a balanced BFS descent and customizable commands";
    homepage = "https://dystroy.org/broot/";
    changelog = "https://github.com/Canop/broot/releases/tag/v${finalAttrs.version}";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ dywedir ];
    mainProgram = "broot";
  };
})
