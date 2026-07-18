{
  lib,
  stdenv,
  cmake,
  fetchFromGitea,
  nlohmann_json,
  qt6,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "swaymux";
  version = "1.1";

  src = fetchFromGitea {
    owner = "Grimmauld";
    repo = "swaymux";
    rev = "v${finalAttrs.version}";
    hash = "sha256-OMJ9wKNuvD1Z9KV7Bp7aIA5gWbBl9PmTdGcGegE0vqM=";
    domain = "git.grimmauld.de";
  };

  nativeBuildInputs = [
    cmake
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    qt6.qtwayland
    nlohmann_json
    qt6.qtbase
  ];

  doCheck = true;

  meta = {
    description = "Program to quickly navigate sway";

    longDescription = ''
      Swaymux allows the user to quickly navigate and administrate outputs, workspaces and containers in a tmux-style approach.
    '';

    homepage = "https://git.grimmauld.de/Grimmauld/swaymux";
    changelog = "https://git.grimmauld.de/Grimmauld/swaymux/commits/branch/main";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ grimmauld ];
    platforms = lib.platforms.linux;
    mainProgram = "swaymux";
  };
})
