{
  lib,
  fetchFromGitHub,
  dconf,
  gnome-shell,
  python3,
  stdenvNoCC,
  writableTmpDirAsHomeHook,
  additionalInstallationTweaks ? [ ], # Additional installation tweaks
  colors ? [ "all" ], # Default to install all available colors
}:

assert lib.assertMsg (colors != [ ]) "The `colors` list can not be empty";

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "marble-shell-theme";
  version = "48.3.2";

  src = fetchFromGitHub {
    owner = "imarkoff";
    repo = "Marble-shell-theme";
    tag = finalAttrs.version;
    hash = "sha256-EYQmtVq852YG4Pmk6Nj4RF+aZUJmIZwhegHIR+Xxu8A=";
  };

  postPatch = ''
    substituteInPlace scripts/config.py \
      --replace-fail "~/.themes" ".themes"
  '';

  nativeBuildInputs = [
    python3
    gnome-shell
    dconf
    writableTmpDirAsHomeHook
  ];

  installPhase = ''
    runHook preInstall

    python install.py ${
      lib.escapeShellArgs (map (color: "--${color}") colors)
    } ${lib.escapeShellArgs additionalInstallationTweaks}
    mkdir -p $out/share
    cp -r .themes $out/share/themes

    runHook postInstall
  '';

  meta = {
    description = "Shell theme for GNOME DE";
    homepage = "https://github.com/imarkoff/Marble-shell-theme";
    changelog = "https://github.com/imarkoff/Marble-shell-theme/releases/tag/${finalAttrs.version}";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };
})
