{
  lib,
  fetchFromGitLab,
  gobject-introspection,
  gtk3,
  libappindicator-gtk3,
  libx11,
  libxtst,
  python3,
  slop,
  wrapGAppsHook3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "screenkey";
  version = "1.5";

  src = fetchFromGitLab {
    owner = "screenkey";
    repo = "screenkey";
    rev = "v${finalAttrs.version}";
    hash = "sha256-kWktKzRyWHGd1lmdKhPwrJoSzAIN2E5TKyg30uhM4Ug=";
  };

  # Fix CDLL python calls for non absolute paths of xorg libraries
  postPatch = ''
    substituteInPlace Screenkey/xlib.py \
      --replace-fail libX11.so.6 ${lib.getLib libx11}/lib/libX11.so.6 \
      --replace-fail libXtst.so.6 ${lib.getLib libxtst}/lib/libXtst.so.6
  '';

  nativeBuildInputs = [
    wrapGAppsHook3
    # for setup hook
    gobject-introspection
  ];

  buildInputs = [
    gtk3
    libappindicator-gtk3
  ];

  # screenkey does not have any tests
  doCheck = false;

  preFixup = ''
    makeWrapperArgs+=(
      --prefix PATH ":" "${lib.makeBinPath [ slop ]}"
      "''${gappsWrapperArgs[@]}"
      )
  '';

  build-system = with python3.pkgs; [ setuptools ];

  dependencies = with python3.pkgs; [
    babel
    pycairo
    pygobject3
    dbus-python
  ];

  # Prevent double wrapping because of wrapGAppsHook3
  dontWrapGApps = true;
  pyproject = true;
  pythonImportsCheck = [ "Screenkey" ];

  meta = {
    description = "Screencast tool to display your keys inspired by Screenflick";
    homepage = "https://www.thregr.org/~wavexx/software/screenkey/";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "screenkey";
  };
})
