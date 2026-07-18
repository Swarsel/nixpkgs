{
  lib,
  stdenv,
  fetchFromGitHub,
  buildNpmPackage,
  chromedriver,
  chromium,
  coreutils,
  ffmpeg-headless,
  firefox,
  geckodriver,
  imagemagick_light,
  nix-update-script,
  procps,
  python3,
  systemdLibs,
  versionCheckHook,
  xorg-server,
  # chromedriver is more efficient than geckodriver, but is available on less platforms.
  withChromium ? (lib.elem stdenv.hostPlatform.system chromedriver.meta.platforms),
  withFirefox ? (lib.elem stdenv.hostPlatform.system geckodriver.meta.platforms),
}:
assert
  (!withFirefox && !withChromium) -> throw "Either `withFirefox` or `withChromium` must be enabled.";
buildNpmPackage (finalAttrs: {
  pname = "sitespeed-io";
  version = "39.4.2";

  src = fetchFromGitHub {
    owner = "sitespeedio";
    repo = "sitespeed.io";
    tag = "v${finalAttrs.version}";
    hash = "sha256-klPdbYVeV4hrwMfwmOiocB4YkJzZsRKUelBZSO+fB/w=";
  };

  buildInputs = [
    systemdLibs
  ];

  npmDepsHash = "sha256-4BvB49+ujSB5XM/BvOqoqRjC7X9Ih3dzt5AQdL3f2z4=";

  env = {
    # Don't try to download the browser drivers
    CHROMEDRIVER_SKIP_DOWNLOAD = true;
    EDGEDRIVER_SKIP_DOWNLOAD = true;
    GECKODRIVER_SKIP_DOWNLOAD = true;
  };

  postInstall = ''
    mv $out/bin/sitespeed{.,-}io
    mv $out/bin/sitespeed{.,-}io-wpr
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  postFixup =
    let
      chromiumArgs = lib.concatStringsSep " " [
        "--browsertime.chrome.chromedriverPath=${lib.getExe chromedriver}"
        "--browsertime.chrome.binaryPath=${lib.getExe chromium}"
      ];
      firefoxArgs = lib.concatStringsSep " " [
        "--browsertime.firefox.geckodriverPath=${lib.getExe geckodriver}"
        "--browsertime.firefox.binaryPath=${lib.getExe firefox}"
        # Firefox crashes if the profile template dir is not writable
        "--browsertime.firefox.profileTemplate=$(mktemp -d)"
      ];
    in
    ''
      wrapProgram $out/bin/sitespeed-io \
        --set PATH ${
          lib.makeBinPath [
            (python3.withPackages (p: [
              p.numpy
              p.opencv4
              p.pyssim
            ]))
            ffmpeg-headless
            imagemagick_light
            xorg-server
            procps
            coreutils
          ]
        } \
        ${lib.optionalString withChromium "--add-flags '${chromiumArgs}'"} \
        ${lib.optionalString withFirefox "--add-flags '${firefoxArgs}'"} \
        ${lib.optionalString (!withFirefox && withChromium) "--add-flags '-b chrome'"} \
        ${lib.optionalString (withFirefox && !withChromium) "--add-flags '-b firefox'"}
    '';

  dontNpmBuild = true;
  npmInstallFlags = [ "--omit=dev" ];

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Open source tool that helps you monitor, analyze and optimize your website speed and performance";
    homepage = "https://sitespeed.io";
    changelog = "https://github.com/sitespeedio/sitespeed.io/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ misterio77 ];
    platforms = lib.unique (geckodriver.meta.platforms ++ chromedriver.meta.platforms);
    mainProgram = "sitespeed-io";
    downloadPage = "https://github.com/sitespeedio/sitespeed.io";
  };
})
