{
  lib,
  stdenv,
  fetchFromGitHub,
  bash,
  cairo,
  gdk-pixbuf,
  jq,
  meson,
  ninja,
  pango,
  pkg-config,
  scdoc,
  systemdMinimal,
  wayland,
  wayland-protocols,
  wayland-scanner,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mako";
  version = "1.11.0";

  src = fetchFromGitHub {
    owner = "emersion";
    repo = "mako";
    tag = "v${finalAttrs.version}";
    hash = "sha256-opCAkYVhp2zQNEi4NBiFfXsC0DdL0kZtaXS9/epzF10=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    scdoc
    wayland-protocols
    wrapGAppsHook3
    wayland-scanner
  ];

  buildInputs = [
    systemdMinimal
    pango
    cairo
    gdk-pixbuf
    wayland
  ];

  mesonFlags = [
    "-Dzsh-completions=true"
    "-Dsd-bus-provider=libsystemd"
  ];

  postInstall = ''
    mkdir -p $out/lib/systemd/user
    substitute $src/contrib/systemd/mako.service $out/lib/systemd/user/mako.service \
      --replace-fail '/usr/bin' "$out/bin"
    chmod 0644 $out/lib/systemd/user/mako.service
  '';

  preFixup = ''
    gappsWrapperArgs+=(
      --prefix PATH : "${
        lib.makeBinPath [
          systemdMinimal # for busctl
          jq
          bash
        ]
      }"
    )
  '';

  depsBuildBuild = [ pkg-config ];

  meta = {
    description = "Lightweight Wayland notification daemon";
    homepage = "https://github.com/emersion/mako";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      dywedir
    ];

    platforms = lib.platforms.linux;
    mainProgram = "mako";
  };
})
