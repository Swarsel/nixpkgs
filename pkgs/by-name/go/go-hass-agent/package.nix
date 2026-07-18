{
  lib,
  fetchFromGitHub,
  buildGoModule,
  fetchNpmDeps,
  nix-update-script,
  nodejs,
  npmHooks,
}:
buildGoModule (finalAttrs: {
  pname = "go-hass-agent";
  version = "14.14.1";

  src = fetchFromGitHub {
    owner = "joshuar";
    repo = "go-hass-agent";
    tag = "v${finalAttrs.version}";
    hash = "sha256-s5kzxzyfNGK57MtusjEjcm0Gn75Wu8vfwJEIaVz7m20=";
  };

  nativeBuildInputs = [
    nodejs
    npmHooks.npmConfigHook
  ];

  vendorHash = "sha256-ZiLYnEcugciobjAchzJZNQrE3G11ehf3vi6cIMxZiTQ=";

  preBuild = ''
    npm run build:js
    npm run build:css
  '';

  desktopItems = [ "assets/start-go-hass-agent.desktop" ];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/joshuar/go-hass-agent/config.AppVersion=v${finalAttrs.version}"
  ];

  npmDeps = fetchNpmDeps {
    inherit (finalAttrs) src;
    hash = "sha256-K/VrxDlE3MVDBItsx4ADkAgn3W06onfVwpBYoU3kejs=";
  };

  overrideModAttrs = oldAttrs: {
    nativeBuildInputs = lib.filter (drv: drv != npmHooks.npmConfigHook) oldAttrs.nativeBuildInputs;
    preBuild = "";
  };

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Home Assistant native app for desktop/laptop devices";

    longDescription = ''
      Go Hass Agent is an application to expose sensors, controls, and events
      from a device to Home Assistant. You can think of it as something similar
      to the Home Assistant companion app for mobile devices, but for your
      desktop, server, Raspberry Pi, Arduino, toaster, whatever. If it can run
      Go and Linux, it can run Go Hass Agent!

      Out of the box, Go Hass Agent will report lots of details about the system
      it is running on. You can extend it with additional sensors and controls
      by hooking it up to MQTT. You can extend it even further with your own
      custom sensors and controls with scripts/programs.

      You can then use these sensors, controls, or events in any automations and
      dashboards, just like the companion app or any other “thing” you've added
      into Home Assistant.
    '';

    homepage = "https://github.com/joshuar/go-hass-agent";
    changelog = "https://github.com/joshuar/go-hass-agent/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      ethancedwards8
      nadir-ishiguro
    ];

    platforms = lib.platforms.linux;
    mainProgram = "go-hass-agent";
  };
})
