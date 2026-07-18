{
  lib,
  stdenv,
  fetchFromGitHub,
  cargo,
  gdk-pixbuf,
  glib,
  gtk3,
  pkg-config,
  rustPlatform,
  rustc,
  versionCheckHook,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "popsicle";
  version = "1.3.3";

  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "popsicle";
    tag = finalAttrs.version;
    hash = "sha256-sWQNav7odvX+peDglLHd7Jrmvhm5ddFBLBla0WK7wcE=";
  };

  nativeBuildInputs = [
    cargo
    glib
    pkg-config
    rustPlatform.bindgenHook
    rustPlatform.cargoSetupHook
    rustc
    wrapGAppsHook3
  ];

  buildInputs = [
    gdk-pixbuf
    gtk3
  ];

  makeFlags = [
    "prefix=$(out)"
  ];

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version src;
    hash = "sha256-KWVX5eOewARccI+ukNfEn8Wc3He1lWXjm9E/Dl0LuM4=";
  };

  meta = {
    description = "Multiple USB File Flasher";
    homepage = "https://github.com/pop-os/popsicle";
    changelog = "https://github.com/pop-os/popsicle/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      _13r0ck
    ];

    platforms = lib.platforms.linux;
  };
})
