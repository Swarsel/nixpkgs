{
  lib,
  stdenv,
  fetchFromGitHub,
  dbus,
  nix-update-script,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "nu_plugin_dbus";
  version = "0.14.0";

  src = fetchFromGitHub {
    owner = "devyn";
    repo = "nu_plugin_dbus";
    tag = finalAttrs.version;
    hash = "sha256-Ga+1zFwS/v+3iKVEz7TFmJjyBW/gq6leHeyH2vjawto=";
  };

  nativeBuildInputs = [ pkg-config ] ++ lib.optionals stdenv.cc.isClang [ rustPlatform.bindgenHook ];
  buildInputs = [ dbus ];
  cargoHash = "sha256-7pD5LA1ytO7VqFnHwgf7vW9eS3olnZBgdsj+rmcHkbU=";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Nushell plugin for communicating with D-Bus";
    homepage = "https://github.com/devyn/nu_plugin_dbus";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ aftix ];
    platforms = lib.platforms.linux;
    mainProgram = "nu_plugin_dbus";
    # "Plugin `dbus` is compiled for nushell version 0.101.0, which is not
    # compatible with version 0.105.1"
    broken = true;
  };
})
