{
  lib,
  fetchFromGitLab,
  nix-update-script,
  stdenvNoCC,
  udevCheckHook,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "xr-hardware";
  version = "1.1.1";

  src = fetchFromGitLab {
    owner = "monado/utilities";
    repo = "xr-hardware";
    tag = finalAttrs.version;
    hash = "sha256-w35/LoozCJz0ytHEHWsEdCaYYwyGU6sE13iMckVdOzY=";
    domain = "gitlab.freedesktop.org";
  };

  nativeBuildInputs = [
    udevCheckHook
  ];

  doInstallCheck = true;
  dontBuild = true;
  dontConfigure = true;
  installFlags = "DESTDIR=${placeholder "out"}";
  installTargets = "install_package";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Hardware description for XR devices";
    homepage = "https://gitlab.freedesktop.org/monado/utilities/xr-hardware";
    license = lib.licenses.boost;
    maintainers = with lib.maintainers; [ Scrumplex ];
    platforms = lib.platforms.linux;
  };
})
