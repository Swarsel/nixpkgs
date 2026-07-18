{
  lib,
  stdenv,
  cargo,
  meson,
  ninja,
  oo7,
  pkg-config,
  rustPlatform,
  rustc,
  systemdLibs,
  useWrappedDaemon ? true,
}:
stdenv.mkDerivation (finalAttrs: {
  inherit (oo7) version src cargoDeps;
  pname = "oo7-server";

  nativeBuildInputs = [
    pkg-config
    meson
    ninja
    rustPlatform.cargoSetupHook
    rustc
    cargo
  ];

  buildInputs = [
    systemdLibs
  ];

  postFixup = lib.optionalString useWrappedDaemon ''
    substituteInPlace "$out/share/systemd/user/oo7-daemon.service" \
      --replace-fail "$out/libexec/oo7-daemon" "/run/wrappers/bin/oo7-daemon"
  '';

  cargoRoot = "../";
  sourceRoot = "${finalAttrs.src.name}/server";

  meta = {
    inherit (oo7.meta)
      homepage
      changelog
      license
      maintainers
      platforms
      ;

    description = "${oo7.meta.description} (Daemon)";
  };
})
