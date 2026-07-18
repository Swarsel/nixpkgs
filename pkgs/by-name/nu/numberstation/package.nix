{
  lib,
  fetchurl,
  desktop-file-utils,
  fetchFromSourcehut,
  glib,
  gobject-introspection,
  gtk3,
  libhandy,
  librsvg,
  meson,
  ninja,
  pkg-config,
  python3,
  wrapGAppsHook3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "numberstation";
  version = "1.5.0";

  src = fetchFromSourcehut {
    owner = "~martijnbraam";
    repo = "numberstation";
    tag = finalAttrs.version;
    hash = "sha256-N8hTXlJcekg/+dCK/tp2EhbNBtj8n9K3LHURRI5ruQQ=";
  };

  patches = [
    (fetchurl {
      hash = "sha256-grTSKdXl1WIK+n4rOe/g4lczc8eIuCU1ZqHI1VNkJ8w=";
      url = "https://src.fedoraproject.org/rpms/numberstation/raw/05cb9e58d879cd9d224862bb72c373374de63943/f/0001-Fix-if-statement-after-b32decode-removal.patch";
    })
  ];

  postPatch = ''
    patchShebangs build-aux/meson
  '';

  nativeBuildInputs = [
    desktop-file-utils
    glib
    gtk3
    gobject-introspection
    meson
    ninja
    pkg-config
    wrapGAppsHook3
  ];

  buildInputs = [
    gtk3
    libhandy
    librsvg
  ];

  propagatedBuildInputs = with python3.pkgs; [
    keyring
    pygobject3
    pyotp
  ];

  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  dontWrapGApps = true;
  pyproject = false;

  meta = {
    description = "TOTP Authentication application for mobile";
    homepage = "https://sr.ht/~martijnbraam/numberstation/";
    changelog = "https://git.sr.ht/~martijnbraam/numberstation/refs/${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ dotlambda ];
    mainProgram = "numberstation";
  };
})
