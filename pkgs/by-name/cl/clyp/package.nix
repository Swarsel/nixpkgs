{
  lib,
  fetchFromGitHub,
  buildGoModule,
  gobject-introspection,
  gtk4,
  pkg-config,
  wrapGAppsHook4,
}:

buildGoModule (finalAttrs: {
  pname = "clyp";
  version = "0.9.6";

  src = fetchFromGitHub {
    owner = "murat-cileli";
    repo = "clyp";
    tag = finalAttrs.version;
    hash = "sha256-7M5LlZKDfY/z8lBfEYeChQprkRRRfOZ3IIn5QuEdQJI=";
  };

  nativeBuildInputs = [
    pkg-config
    wrapGAppsHook4
  ];

  buildInputs = [
    gobject-introspection
    gtk4
  ];

  vendorHash = null;
  ldflags = [ "-s" ];

  meta = {
    description = "Clipboard manager for Linux";
    homepage = "https://github.com/murat-cileli/clyp";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ paperdigits ];
    mainProgram = "clyp";
  };
})
