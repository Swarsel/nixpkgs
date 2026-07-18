{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  cmake,
  git,
  go,
  kdePackages,
  nlohmann_json,
}:

let
  version = "0.22.1";

  src = fetchFromGitHub {
    owner = "f-koehler";
    repo = "KTailctl";
    tag = "v${version}";
    hash = "sha256-BRkjVZaoxiMW8JltIkYDiCCE2kNGLDpRJd0iclQMcGY=";
  };

  goDeps =
    (buildGoModule {
      inherit src version;
      pname = "ktailctl-go-wrapper";
      vendorHash = "sha256-h2gf9igVOguNRroGK6qvinUlEkpeZ2YJTtKArvlMj88=";
      modRoot = "src/tailscale/wrapper";
    }).goModules;
in
stdenv.mkDerivation {
  inherit version src;
  pname = "ktailctl";

  postPatch = ''
    cp -r --reflink=auto ${goDeps} src/tailscale/wrapper/vendor
  '';

  nativeBuildInputs = with kdePackages; [
    cmake
    extra-cmake-modules
    git
    go
    wrapQtAppsHook
  ];

  buildInputs = with kdePackages; [
    kconfig
    kcoreaddons
    kdbusaddons
    kguiaddons
    ki18n
    kirigami
    kirigami-addons
    knotifications
    kwindowsystem
    nlohmann_json
    qqc2-desktop-style
    qtbase
    qtdeclarative
    qtsvg
    qtwayland
  ];

  cmakeFlags = [
    # actually just disables Go vendoring updates
    "-DKTAILCTL_FLATPAK_BUILD=ON"
  ];

  # needed for go build to work
  preBuild = ''
    export HOME=$TMPDIR
  '';

  meta = {
    description = "GUI to monitor and manage Tailscale on your Linux desktop";
    homepage = "https://github.com/f-koehler/KTailctl";
    changelog = "https://github.com/f-koehler/KTailctl/releases/tag/${src.tag}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ k900 ];
    platforms = lib.platforms.unix;
    mainProgram = "ktailctl";
  };
}
