{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  bison,
  common-updater-scripts,
  curl,
  jq,
  libevent,
  libutempter,
  ncurses,
  pkg-config,
  runCommand,
  systemdLibs,
  utf8proc, # gets Unicode updates faster than glibc
  versionCheckHook,
  writeShellScript,
  withSixel ? true,
  withSystemd ? lib.meta.availableOn stdenv.hostPlatform systemdLibs,
  withUtempter ? stdenv.hostPlatform.isLinux,
  # broken on i686-linux https://github.com/tmux/tmux/issues/4597
  withUtf8proc ? !(stdenv.hostPlatform.is32bit),
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "tmux";
  version = "3.7b";

  src = fetchFromGitHub {
    owner = "tmux";
    repo = "tmux";
    tag = finalAttrs.version;
    hash = "sha256-CTq06XP997M0ODxQihTq34dI9H6jSRLUXLYuTWOwDpc=";
  };

  outputs = [
    "out"
    "man"
  ];

  nativeBuildInputs = [
    pkg-config
    autoreconfHook
    bison
  ];

  buildInputs = [
    ncurses
    libevent
  ]
  ++ lib.optionals withSystemd [ systemdLibs ]
  ++ lib.optionals withUtf8proc [ utf8proc ]
  ++ lib.optionals withUtempter [ libutempter ];

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
  ]
  ++ lib.optionals withSystemd [ "--enable-systemd" ]
  ++ lib.optionals withSixel [ "--enable-sixel" ]
  ++ lib.optionals withUtempter [ "--enable-utempter" ]
  ++ lib.optionals withUtf8proc [ "--enable-utf8proc" ];

  postInstall = lib.optionalString stdenv.hostPlatform.isDarwin ''
    mkdir $out/nix-support
    echo "${finalAttrs.passthru.terminfo}" >> $out/nix-support/propagated-user-env-packages
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  enableParallelBuilding = true;
  versionCheckProgramArg = "-V";

  passthru = {
    terminfo = runCommand "tmux-terminfo" { nativeBuildInputs = [ ncurses ]; } (
      if stdenv.hostPlatform.isDarwin then
        ''
          mkdir -p $out/share/terminfo/74
          cp -v ${ncurses}/share/terminfo/74/tmux $out/share/terminfo/74
          # macOS ships an old version (5.7) of ncurses which does not include tmux-256color so we need to provide it from our ncurses.
          # However, due to a bug in ncurses 5.7, we need to first patch the terminfo before we can use it with macOS.
          # https://gpanders.com/blog/the-definitive-guide-to-using-tmux-256color-on-macos/
          tic -o $out/share/terminfo -x <(TERMINFO_DIRS=${ncurses}/share/terminfo infocmp -x tmux-256color | sed 's|pairs#0x10000|pairs#32767|')
        ''
      else
        ''
          mkdir -p $out/share/terminfo/t
          ln -sv ${ncurses}/share/terminfo/t/{tmux,tmux-256color,tmux-direct} $out/share/terminfo/t
        ''
    );

    updateScript = writeShellScript "update-tmux" ''
      latest=$(${lib.getExe curl} --silent ''${GITHUB_TOKEN:+--header "Authorization: Bearer $GITHUB_TOKEN"} https://api.github.com/repos/tmux/tmux/releases/latest | ${lib.getExe jq} -r .tag_name)
      ${lib.getExe' common-updater-scripts "update-source-version"} tmux "$latest"
    '';
  };

  meta = {
    description = "Terminal multiplexer";

    longDescription = ''
      tmux is intended to be a modern, BSD-licensed alternative to programs such as GNU screen. Major features include:
        * A powerful, consistent, well-documented and easily scriptable command interface.
        * A window may be split horizontally and vertically into panes.
        * Panes can be freely moved and resized, or arranged into preset layouts.
        * Support for UTF-8 and 256-colour terminals.
        * Copy and paste with multiple buffers.
        * Interactive menus to select windows, sessions or clients.
        * Change the current window by searching for text in the target.
        * Terminal locking, manually or after a timeout.
        * A clean, easily extended, BSD-licensed codebase, under active development.
    '';

    homepage = "https://tmux.github.io/";
    changelog = "https://github.com/tmux/tmux/raw/${finalAttrs.version}/CHANGES";
    license = lib.licenses.bsd3;

    maintainers = with lib.maintainers; [
      ethancedwards8
      fpletz
    ];

    platforms = lib.platforms.unix;
    mainProgram = "tmux";
    downloadPage = "https://github.com/tmux/tmux";
  };
})
