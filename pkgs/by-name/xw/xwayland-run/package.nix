{
  lib,
  fetchFromGitLab,
  cage,
  dbus, # Since 0.0.3, mutter compositors run with their own DBUS sessions
  kdePackages,
  meson,
  mutter,
  ninja,
  phoc,
  python3,
  weston,
  xauth,
  xwayland,
  xwayland-run,
  withCage ? false,
  withDbus ? withMutter,
  withKwin ? false,
  withMutter ? false,
  withPhoc ? false,
}:
let
  compositors = [
    weston
  ]
  ++ lib.optional withCage cage
  ++ lib.optional withKwin kdePackages.kwin
  ++ lib.optional withMutter mutter
  ++ lib.optional withPhoc phoc
  ++ lib.optional withDbus dbus;
in
python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "xwayland-run";
  version = "0.0.6";

  src = fetchFromGitLab {
    owner = "ofourdan";
    repo = "xwayland-run";
    rev = finalAttrs.version;
    hash = "sha256-zrm8uEy7DduOYPrpHrynZgYwEkZr3pbDsJHdWKOUzY0=";
    domain = "gitlab.freedesktop.org";
  };

  outputs = [
    "out"
    "man"
  ];

  nativeBuildInputs = [
    meson
    ninja
  ];

  postInstall = ''
    wrapProgram $out/bin/wlheadless-run \
      --prefix PATH : ${lib.makeBinPath compositors}
    wrapProgram $out/bin/xwayland-run \
      --prefix PATH : ${
        lib.makeBinPath [
          xwayland
          xauth
        ]
      }
    wrapProgram $out/bin/xwfb-run \
      --prefix PATH : ${
        lib.makeBinPath (
          compositors
          ++ [
            xwayland
            xauth
          ]
        )
      }
  '';

  pyproject = false;

  passthru.tests = {
    build = xwayland-run.override {
      withCage = true;
      withKwin = true;
      withMutter = true;
      withPhoc = true;
    };
  };

  meta = {
    description = "Set of small utilities revolving around running Xwayland and various Wayland compositor headless";
    homepage = "https://gitlab.freedesktop.org/ofourdan/xwayland-run";
    changelog = "https://gitlab.freedesktop.org/ofourdan/xwayland-run/-/releases/${finalAttrs.src.rev}";
    license = lib.licenses.gpl2Only;
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };
})
