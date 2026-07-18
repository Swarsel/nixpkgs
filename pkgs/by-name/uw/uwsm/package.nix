{
  lib,
  stdenv,
  fetchFromGitHub,
  bash,
  dmenu,
  fetchpatch,
  libnotify,
  makeBinaryWrapper,
  meson,
  newt,
  ninja,
  nix-update-script,
  pkg-config,
  python3Packages,
  scdoc,
  systemd,
  util-linux,
  fumonSupport ? true,
  uuctlSupport ? true,
  uwsmAppSupport ? true,
}:
let
  python = python3Packages.python.withPackages (ps: [
    ps.pydbus
    ps.dbus-python
    ps.pyxdg
  ]);
in
stdenv.mkDerivation (finalAttrs: {
  pname = "uwsm";
  version = "0.26.6";

  src = fetchFromGitHub {
    owner = "Vladimir-csp";
    repo = "uwsm";
    tag = "v${finalAttrs.version}";
    hash = "sha256-5wfQ2Iv4j2Gd/CV1BQ7mdkIXG7sA90iMiBAefmM3BvY=";
  };

  outputs = [
    "out"
    "man"
  ];

  nativeBuildInputs = [
    makeBinaryWrapper
    meson
    ninja
    pkg-config
    scdoc
  ];

  buildInputs = [
    util-linux # waitpid
    newt # whiptail
    libnotify # notify-send
    bash # sh
    systemd
    python
  ]
  ++ lib.optionals uuctlSupport [ dmenu ];

  mesonFlags = [
    "--prefix=${placeholder "out"}"
  ]
  ++ (lib.mapAttrsToList lib.mesonEnable {
    "canonicalize-bins" = true;
    "fumon" = fumonSupport;
    "man-pages" = true;
    "uuctl" = uuctlSupport;
    "uwsm-app" = uwsmAppSupport;
  })
  ++ (lib.mapAttrsToList lib.mesonOption {
    "python-bin" = python.interpreter;
  });

  postInstall =
    let
      wrapperArgs = "--suffix PATH : ${lib.makeBinPath finalAttrs.buildInputs}";
    in
    lib.optionalString uuctlSupport ''
      wrapProgram $out/bin/uuctl ${wrapperArgs}
    ''
    + lib.optionalString uwsmAppSupport ''
      wrapProgram $out/bin/uwsm-app ${wrapperArgs}
    ''
    + lib.optionalString fumonSupport ''
      wrapProgram $out/bin/fumon ${wrapperArgs}
    '';

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Universal wayland session manager";
    homepage = "https://github.com/Vladimir-csp/uwsm";
    changelog = "https://github.com/Vladimir-csp/uwsm/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      johnrtitor
      kai-tub
    ];

    platforms = lib.platforms.linux;
    mainProgram = "uwsm";
  };
})
