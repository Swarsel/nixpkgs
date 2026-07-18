{
  lib,
  fetchFromGitHub,
  nix-update-script,
  nixosTests,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "scx-loader";
  version = "1.1.2";

  src = fetchFromGitHub {
    owner = "sched-ext";
    repo = "scx-loader";
    tag = "v${finalAttrs.version}";
    hash = "sha256-SFolb2S7HGSsUPxXtiVCv/6N4XNqOU62c3GZX9axk9k=";
  };

  cargoHash = "sha256-jzp1Z64p35Ap6TYuN977up8Ls8Jakfz9CeM5+brgtuQ=";

  env = {
    VENDOR_DATADIR = "/share";
    VENDOR_PREFIX = "";
  };

  postInstall = ''
    cargo xtask install --destdir $out
    rm $out/bin/xtask
  '';

  postFixup = ''
    substituteInPlace $out/lib/systemd/system/scx_loader.service \
      --replace-fail "/usr/bin/scx_loader" "$out/bin/scx_loader"
    substituteInPlace $out/share/dbus-1/system-services/org.scx.Loader.service \
      --replace-fail "/usr/bin/scx_loader" "$out/bin/scx_loader"
  '';

  __structuredAttrs = true;

  passthru = {
    tests = { inherit (nixosTests) scx-loader; };
    updateScript = nix-update-script { };
  };

  meta = {
    homepage = "https://github.com/sched-ext/scx-loader";
    changelog = "https://github.com/sched-ext/scx-loader/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.gpl2Only;

    maintainers = with lib.maintainers; [
      Gliczy
      michaelBelsanti
      ccicnce113424
    ];

    platforms = lib.platforms.linux;
    mainProgram = "scxctl";
  };
})
