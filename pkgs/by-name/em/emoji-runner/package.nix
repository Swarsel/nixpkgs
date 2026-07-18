{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  gettext,
  kdePackages,
  nix-update-script,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "emoji-runner";
  version = "3.0.5";

  src = fetchFromGitHub {
    owner = "alex1701c";
    repo = "EmojiRunner";
    tag = finalAttrs.version;
    hash = "sha256-Rt7Z0uEbzqRKxV1EpDr//RYaVr3D+Nj+7JS3EAO+hsM=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    gettext
    kdePackages.extra-cmake-modules
  ];

  buildInputs = with kdePackages; [
    ki18n
    kservice
    krunner
    ktextwidgets
    kcmutils
    kconfigwidgets
  ];

  cmakeFlags = [
    "-DBUILD_TESTING=OFF"
    "-DBUILD_WITH_QT6=ON"
    "-DQT_MAJOR_VERSION=6"
  ];

  dontWrapQtApps = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    inherit (kdePackages.krunner.meta) platforms;
    description = "Search for emojis in Krunner and copy/paste them";
    homepage = "https://github.com/alex1701c/EmojiRunner";
    changelog = "https://github.com/alex1701c/EmojiRunner/releases/tag/${finalAttrs.version}";
    license = lib.licenses.lgpl3Only;
    maintainers = with lib.maintainers; [ Kladki ];
  };
})
