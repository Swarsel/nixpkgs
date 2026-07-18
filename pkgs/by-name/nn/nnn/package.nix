{
  lib,
  stdenv,
  fetchFromGitHub,
  file,
  gnused,
  installShellFiles,
  makeWrapper,
  musl-fts,
  ncurses,
  pcre2,
  pkg-config,
  readline,
  which,
  # options
  conf ? null,
  extraMakeFlags ? [ ],
  withEmojis ? false,
  withIcons ? false,
  withNerdIcons ? false,
  withPcre ? false,
}:

# Mutually exclusive options
assert withIcons -> (!withNerdIcons && !withEmojis);
assert withNerdIcons -> (!withIcons && !withEmojis);
assert withEmojis -> (!withIcons && !withNerdIcons);

stdenv.mkDerivation (finalAttrs: {
  pname = "nnn";
  version = "5.2";

  src = fetchFromGitHub {
    owner = "jarun";
    repo = "nnn";
    tag = "v${finalAttrs.version}";
    hash = "sha256-u+88aDHfOZ6bSkg6ahS6eNZWj2QCwJXKW+8nHR99kic=";
  };

  patches = [
    # Nix-specific: ensure nnn passes correct arguments to the Nix file command on Darwin.
    # By default, nnn expects the macOS default file command, not the one provided by Nix.
    # However, both commands use different arguments to obtain the MIME type.
    ./darwin-fix-file-mime-opts.patch
  ];

  nativeBuildInputs = [
    installShellFiles
    makeWrapper
    pkg-config
  ];

  buildInputs = [
    readline
    ncurses
  ]
  ++ lib.optional stdenv.hostPlatform.isMusl musl-fts
  ++ lib.optional withPcre pcre2;

  makeFlags = [
    "PREFIX=$(out)"
  ]
  ++ lib.optionals withIcons [ "O_ICONS=1" ]
  ++ lib.optionals withNerdIcons [ "O_NERD=1" ]
  ++ lib.optionals withEmojis [ "O_EMOJI=1" ]
  ++ lib.optionals withPcre [ "O_PCRE2=1" ]
  ++ extraMakeFlags;

  env = lib.optionalAttrs stdenv.hostPlatform.isMusl {
    NIX_CFLAGS_COMPILE = "-I${musl-fts}/include";
    NIX_LDFLAGS = "-lfts";
  };

  preBuild = lib.optionalString (conf != null) "cp ${finalAttrs.configFile} src/nnn.h";

  postInstall = ''
    installShellCompletion --bash --name nnn.bash misc/auto-completion/bash/nnn-completion.bash
    installShellCompletion --fish misc/auto-completion/fish/nnn.fish
    installShellCompletion --zsh misc/auto-completion/zsh/_nnn

    cp -r plugins $out/share
    cp -r misc/quitcd $out/share/quitcd

    wrapProgram $out/bin/nnn --prefix PATH : "$binPath"
  '';

  binPath = lib.makeBinPath [
    file
    which
    gnused
  ];

  configFile = lib.optionalString (conf != null) (builtins.toFile "nnn.h" conf);

  installTargets = [
    "install"
    "install-desktop"
  ];

  meta = {
    description = "Small ncurses-based file browser forked from noice";
    homepage = "https://github.com/jarun/nnn";
    changelog = "https://github.com/jarun/nnn/blob/v${finalAttrs.version}/CHANGELOG";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ sikmir ];
    platforms = lib.platforms.all;
    mainProgram = "nnn";
  };
})
