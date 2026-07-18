{
  lib,
  fetchFromGitHub,
  libevdev,
  libiio,
  pkg-config,
  rustPlatform,
  udev,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "inputplumber";
  version = "0.77.7";

  src = fetchFromGitHub {
    owner = "ShadowBlip";
    repo = "InputPlumber";
    tag = "v${finalAttrs.version}";
    hash = "sha256-LECHrL+yopymcdpuEZUFvNX1QI30Z+mOtMYP7fnMpBM=";
  };

  nativeBuildInputs = [
    pkg-config
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    udev
    libevdev
    libiio
  ];

  cargoHash = "sha256-1g4nHBu9LUMMr0bPkD4LCEFyyIc+GdhIWu+hlyGH3IM=";

  postInstall = ''
    cp -r rootfs/usr/* $out/
  '';

  meta = {
    description = "Open source input router and remapper daemon for Linux";
    homepage = "https://github.com/ShadowBlip/InputPlumber";
    changelog = "https://github.com/ShadowBlip/InputPlumber/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ shadowapex ];
    mainProgram = "inputplumber";
  };
})
