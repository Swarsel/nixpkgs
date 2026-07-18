{
  lib,
  fetchFromGitLab,
  glib,
  libdrm,
  libgudev,
  meson,
  ninja,
  pkg-config,
  python3Packages,
  systemd,
  wrapGAppsNoGuiHook,
}:

let
  version = "3.0";
in
python3Packages.buildPythonApplication {
  inherit version;
  pname = "switcheroo-control";

  src = fetchFromGitLab {
    owner = "hadess";
    repo = "switcheroo-control";
    tag = version;
    hash = "sha256-7P0o8fBYe4izRmNL7DimUSJfzj13KXW9we6c/A2iNo8=";
    domain = "gitlab.freedesktop.org";
  };

  postPatch = ''
    substituteInPlace data/meson.build \
      --replace-fail "rules_dir" "'${placeholder "out"}/lib/udev/rules.d'"
  '';

  nativeBuildInputs = [
    ninja
    meson
    pkg-config
    wrapGAppsNoGuiHook
  ];

  buildInputs = [
    systemd
    libdrm
    libgudev
    glib
  ];

  mesonFlags = [
    "-Dsystemdsystemunitdir=${placeholder "out"}/etc/systemd/system"
    "-Dhwdbdir=${placeholder "out"}/etc/udev/hwdb.d"
  ];

  dependencies = [
    python3Packages.pygobject3
  ];

  dontWrapGApps = true;
  makeWrapperArgs = [ "\${gappsWrapperArgs[@]}" ];
  pyproject = false;

  meta = {
    description = "D-Bus service to check the availability of dual-GPU";
    homepage = "https://gitlab.freedesktop.org/hadess/switcheroo-control/";
    changelog = "https://gitlab.freedesktop.org/hadess/switcheroo-control/-/blob/${version}/NEWS";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "switcherooctl";
  };
}
