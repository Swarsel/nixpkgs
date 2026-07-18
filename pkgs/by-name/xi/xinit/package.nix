{
  lib,
  stdenv,
  fetchFromGitLab,
  autoreconfHook,
  buildPackages,
  darwin,
  libx11,
  nix-update-script,
  pkg-config,
  util-macros,
  xauth,
  xorg-server,
  xorgproto,
  # path to the X server binary to use - override for setuid, for example: "/run/wrappers/bin/X"
  xserverPath ? "${xorg-server.out}/bin/X",
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "xinit";
  version = "1.4.4";

  src = fetchFromGitLab {
    owner = "app";
    repo = "xinit";
    tag = "xinit-${finalAttrs.version}";
    hash = "sha256-1GL0xJ/l9BnhoUyD5m1Ch86hjcRdBnys366qM4Lj84U=";
    domain = "gitlab.freedesktop.org";
    group = "xorg";
  };

  strictDeps = true;

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
    util-macros
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    darwin.bootstrap_cmds
  ];

  buildInputs = [
    libx11
    xorgproto
  ];

  propagatedBuildInputs = [
    xauth
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    libx11
    xorgproto
  ];

  configureFlags = [
    "--with-xserver=${xserverPath}"
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    "--with-launchd=yes"
    "--with-bundle-id-prefix=org.nixos.xquartz"
    "--with-launchdaemons-dir=${placeholder "out"}/LaunchDaemons"
    "--with-launchagents-dir=${placeholder "out"}/LaunchAgents"
  ];

  postFixup = ''
    substituteInPlace $out/bin/startx \
      --replace-fail '"''${prefix}/etc/X11/xinit/xinitrc"' '/etc/X11/xinit/xinitrc' \
      --replace-fail '"$xinitdir/xserverrc"' '/etc/X11/xinit/xserverrc'
  '';

  depsBuildBuild = [ buildPackages.stdenv.cc ];

  passthru = {
    updateScript = nix-update-script { extraArgs = [ "--version-regex=xinit-(.*)" ]; };
  };

  meta = {
    description = "X server & client startup utilities (includes startx)";
    homepage = "https://gitlab.freedesktop.org/xorg/app/xinit";

    license = with lib.licenses; [
      mitOpenGroup
      x11
    ];

    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "xinit";
  };
})
