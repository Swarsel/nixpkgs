{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  fetchpatch2,
  libcap,
  libnl,
  lm_sensors,
  ncurses,
  pkg-config,
  systemdLibs,
  sensorsSupport ? (stdenv.hostPlatform.isLinux && !stdenv.hostPlatform.isStatic),
  systemdSupport ? lib.meta.availableOn stdenv.hostPlatform systemdLibs,
  withVimKeys ? false,
}:

assert systemdSupport -> stdenv.hostPlatform.isLinux;

stdenv.mkDerivation (finalAttrs: {
  pname = "htop" + lib.optionalString withVimKeys "-vim";
  version = "3.5.1";

  src = fetchFromGitHub {
    owner = "htop-dev";
    repo = "htop";
    tag = finalAttrs.version;
    hash = "sha256-mw7pixNk+AF2Hz8YUkkUleQpR8yNF0pb1NjYgID076A=";
  };

  outputs = [
    "out"
    "man"
  ];

  patches = lib.optional withVimKeys (fetchpatch2 {
    hash = "sha256-fZDTA2dCOmXxUYD6Wm41q7TxL7fgQOj8a/8yJC7Zags=";
    name = "vim-keybindings.patch";
    url = "https://aur.archlinux.org/cgit/aur.git/plain/vim-keybindings.patch?h=htop-vim&id=d10f022b3ca1207200187a55f5b116a5bd8224f7";
  });

  # upstream removed pkg-config support and uses dlopen now
  postPatch =
    let
      libnlPath = lib.getLib libnl;
    in
    lib.optionalString stdenv.hostPlatform.isLinux ''
      substituteInPlace configure.ac \
        --replace-fail /usr/include/libnl3 ${lib.getDev libnl}/include/libnl3
      substituteInPlace linux/LibNl.c \
        --replace-fail libnl-3.so ${libnlPath}/lib/libnl-3.so \
        --replace-fail libnl-genl-3.so ${libnlPath}/lib/libnl-genl-3.so
    '';

  nativeBuildInputs = [ autoreconfHook ] ++ lib.optional stdenv.hostPlatform.isLinux pkg-config;

  buildInputs = [
    ncurses
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    libcap
    libnl
  ]
  ++ lib.optional sensorsSupport lm_sensors
  ++ lib.optional systemdSupport systemdLibs;

  configureFlags = [
    "--enable-unicode"
    "--sysconfdir=/etc"
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    "--enable-affinity"
    "--enable-capabilities"
    "--enable-delayacct"
  ]
  ++ lib.optional sensorsSupport "--enable-sensors";

  postFixup =
    let
      optionalPatch = pred: so: lib.optionalString pred "patchelf --add-needed ${so} $out/bin/htop";
    in
    lib.optionalString (!stdenv.hostPlatform.isStatic) ''
      ${optionalPatch sensorsSupport "${lib.getLib lm_sensors}/lib/libsensors.so"}
      ${optionalPatch systemdSupport "${systemdLibs}/lib/libsystemd.so"}
    '';

  meta = {
    description =
      "Interactive process viewer" + lib.optionalString withVimKeys ", with vim-style keybindings";

    homepage =
      if withVimKeys then "https://aur.archlinux.org/packages/htop-vim" else "https://htop.dev";

    changelog = "https://github.com/htop-dev/htop/blob/${finalAttrs.version}/ChangeLog";
    license = lib.licenses.gpl2Only;

    maintainers = with lib.maintainers; [
      rob
      relrod
      SuperSandro2000
      thiagokokada
    ];

    platforms = lib.platforms.all;
    mainProgram = "htop";
  };
})
