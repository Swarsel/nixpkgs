{
  lib,
  stdenv,
  fetchFromGitHub,
  meson,
  ninja,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "wayland-logout";
  version = "1.4";

  src = fetchFromGitHub {
    owner = "soreau";
    repo = "wayland-logout";
    rev = "v${finalAttrs.version}";
    hash = "sha256-VSAw6go4v937HWazXfMz8OdHgOnUtrlDXkslsV4eDIg=";
  };

  nativeBuildInputs = [
    meson
    ninja
  ];

  meta = {
    description = ''
      A utility designed to kill a single instance of a wayland compositor
    '';

    homepage = "https://github.com/soreau/wayland-logout";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ quantenzitrone ];
    platforms = lib.platforms.linux;
    mainProgram = "wayland-logout";
  };
})
