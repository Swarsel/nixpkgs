{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
  nixosTests,
  versionCheckHook,
  withCollector ? true,
  withHistory ? true,
  # modules (https://github.com/Kioubit/FlapAlerted#module-documentation)
  withHttpApi ? true,
  withLog ? true,
  withRoaFilter ? false,
  withScript ? true,
  withWebhook ? true,
}:

buildGoModule (finalAttrs: {
  pname = "flap-alerted";
  version = "4.5.0";

  src = fetchFromGitHub {
    owner = "Kioubit";
    repo = "FlapAlerted";
    tag = "v${finalAttrs.version}";
    hash = "sha256-D4+FLAMt/cHXCks4GQI33ymbZIHzBajpvKU6QQntofk=";
  };

  vendorHash = null;
  env.CGO_ENABLED = 0;
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  __structuredAttrs = true;

  ldflags = [
    "-s"
    "-w"
    "-X main.Version=v${finalAttrs.version}"
  ];

  tags =
    lib.optionals (!withHttpApi) [ "disable_mod_httpAPI" ]
    ++ lib.optionals (!withLog) [ "disable_mod_log" ]
    ++ lib.optionals (!withScript) [ "disable_mod_script" ]
    ++ lib.optionals (!withWebhook) [ "disable_mod_webhook" ]
    ++ lib.optionals (!withCollector) [ "disable_mod_collector" ]
    ++ lib.optionals (!withHistory) [ "disable_mod_history" ]
    ++ lib.optionals withRoaFilter [ "mod_roaFilter" ];

  passthru = {
    tests = { inherit (nixosTests) flap-alerted; };
    updateScript = nix-update-script { };
  };

  meta = {
    description = "BGP Update based flap detection & statistics";
    homepage = "https://github.com/Kioubit/FlapAlerted";
    changelog = "https://github.com/Kioubit/FlapAlerted/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.agpl3Plus;
    maintainers = with lib.maintainers; [ defelo ];
    mainProgram = "FlapAlerted";
  };
})
