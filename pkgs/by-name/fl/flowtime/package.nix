{
  lib,
  stdenv,
  fetchFromGitHub,
  appstream-glib,
  blueprint-compiler,
  desktop-file-utils,
  gst_all_1,
  libadwaita,
  libportal-gtk4,
  libxml2,
  meson,
  ninja,
  pkg-config,
  vala,
  wrapGAppsHook4,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "flowtime";
  version = "6.5";

  src = fetchFromGitHub {
    owner = "Diego-Ivan";
    repo = "Flowtime";
    rev = "v${finalAttrs.version}";
    hash = "sha256-J0Pscv0ZOpA/LV2mPTLOmDPQpfZhizTghatGnrJHToE=";
  };

  nativeBuildInputs = [
    blueprint-compiler
    desktop-file-utils
    meson
    ninja
    pkg-config
    vala
    wrapGAppsHook4
    appstream-glib
  ];

  buildInputs = [
    libadwaita
    libxml2
    libportal-gtk4
  ]
  ++ (with gst_all_1; [
    gstreamer
    gst-plugins-base
  ]);

  meta = {
    description = "Get what motivates you done, without losing concentration";
    homepage = "https://github.com/Diego-Ivan/Flowtime";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      pokon548
    ];

    platforms = lib.platforms.linux;
    mainProgram = "flowtime";
  };
})
