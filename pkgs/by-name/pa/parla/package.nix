{
  lib,
  stdenv,
  fetchFromGitHub,
  deltachat-rpc-server,
  glib,
  gtk4,
  json-glib,
  libadwaita,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
  vala,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "parla";
  version = "0.6.6";

  src = fetchFromGitHub {
    owner = "trufae";
    repo = "parla";
    tag = finalAttrs.version;
    hash = "sha256-ZSI/dABNaApCXKJkLGXFp1Fp221Axurj/Z3O9Q9pQZk=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    vala
  ];

  buildInputs = [
    glib
    gtk4
    json-glib
    libadwaita
  ];

  mesonFlags = [
    "-Drpc_server_path=${lib.getExe deltachat-rpc-server}"
  ];

  __structuredAttrs = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Native Gnome DeltaChat client";
    homepage = "https://github.com/trufae/parla";
    changelog = "https://github.com/trufae/parla/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.gpl3Only;
    maintainers = [ lib.maintainers.dotlambda ];
    platforms = lib.platforms.linux;
    mainProgram = "parla";
  };
})
