{
  lib,
  stdenv,
  fetchFromGitHub,
  glib,
  gnome-builder,
  json-glib,
  jsonrpc-glib,
  libgee,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
  scdoc,
  vala,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "vala-language-server";
  version = "0.48.7";

  src = fetchFromGitHub {
    owner = "vala-lang";
    repo = "vala-language-server";
    rev = finalAttrs.version;
    sha256 = "sha256-Vl5DjKBdpk03aPD+0xGoTwD9Slg1rREorqZGX5o10cY=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    scdoc
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    # GNOME Builder Plugin
    gnome-builder
  ];

  buildInputs = [
    glib
    libgee
    json-glib
    jsonrpc-glib
    vala
  ];

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Code Intelligence for Vala & Genie";
    homepage = "https://github.com/vala-lang/vala-language-server";
    license = lib.licenses.lgpl21Plus;
    maintainers = with lib.maintainers; [ andreasfelix ];
    platforms = lib.platforms.unix;
    mainProgram = "vala-language-server";
  };
})
