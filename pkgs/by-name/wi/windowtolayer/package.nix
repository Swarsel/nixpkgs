{
  lib,
  fetchFromGitLab,
  nix-update-script,
  python3,
  rustPlatform,
  rustfmt,
}:
rustPlatform.buildRustPackage rec {
  pname = "windowtolayer";
  version = "0.3.1";

  src = fetchFromGitLab {
    owner = "mstoeckl";
    repo = "windowtolayer";
    tag = "v${version}";
    hash = "sha256-TUet9DqLMsY34Mb9t4IKr3Z/JxrPgvufzanHI4D9dZg=";
    domain = "gitlab.freedesktop.org";
  };

  nativeBuildInputs = [
    python3
    rustfmt
  ];

  cargoHash = "sha256-MqcutNzorDeYoGKWFbCzIrNuo1w2vwnGEFOuooZwPgk=";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Display existing Wayland applications as a wallpaper instead";
    homepage = "https://gitlab.freedesktop.org/mstoeckl/windowtolayer";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ anomalocaris ];
    platforms = with lib.platforms; linux ++ freebsd;
    mainProgram = "windowtolayer";
  };
}
