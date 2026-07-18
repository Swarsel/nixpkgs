{
  lib,
  stdenv,
  fetchFromGitHub,
  formats,
  systemd,
}:

let
  ini = formats.ini { };

  unit = ini.generate "systembus-notify.service" {
    Service = {
      ExecStart = "@out@/bin/systembus-notify";
      # NB. We cannot `ProtectHome`, or it would block session dbus access.
      InaccessiblePaths = "/home";
      PrivateTmp = true;
      ProtectSystem = "strict";
      ReadOnlyPaths = "/run/user";
      Restart = "on-failure";
      Slice = "background.slice";
      Type = "exec";
    };

    Unit = {
      Description = "system bus notification daemon";
    };
  };

in
stdenv.mkDerivation (finalAttrs: {
  pname = "systembus-notify";
  version = "1.1";

  src = fetchFromGitHub {
    owner = "rfjakob";
    repo = "systembus-notify";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-WzuBw7LXW54CCMgFE9BSJ2skxaz4IA2BcBny63Ihtt0=";
  };

  buildInputs = [ systemd ];
  # requires a running dbus instance
  doCheck = false;

  installPhase = ''
    runHook preInstall

    install -Dm555 -t $out/bin systembus-notify
    install -Dm444 -t $out/share/systembus-notify systembus-notify.desktop

    install -d $out/lib/systemd/user
    substitute ${unit} $out/lib/systemd/user/${unit.name} \
      --subst-var out

    runHook postInstall
  '';

  meta = {
    description = "System bus notification daemon";
    homepage = "https://github.com/rfjakob/systembus-notify";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ peterhoeg ];
    platforms = lib.platforms.linux;
    mainProgram = "systembus-notify";
  };
})
