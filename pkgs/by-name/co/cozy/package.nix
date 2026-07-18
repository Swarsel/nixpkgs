{
  lib,
  fetchFromGitHub,
  appstream-glib,
  desktop-file-utils,
  gobject-introspection,
  gst_all_1,
  libadwaita,
  meson,
  ninja,
  pkg-config,
  python3Packages,
  wrapGAppsHook4,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "cozy";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "geigi";
    repo = "cozy";
    tag = finalAttrs.version;
    hash = "sha256-oMgdz2dny0u1XV13aHu5s8/pcAz8z/SAOf4hbCDsdjw";
  };

  # FIX: The "Support Debian non-standard python paths" resolves to store path of python
  postPatch = ''
    substituteInPlace meson.build \
      --replace-fail \
        'from distutils.sysconfig import get_python_lib; print(get_python_lib(prefix=""))' \
        "print(\"$out/${python3Packages.python.sitePackages}\")"
  '';

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    wrapGAppsHook4
    appstream-glib
    desktop-file-utils
    gobject-introspection
  ];

  buildInputs = [
    libadwaita
  ]
  ++ (with gst_all_1; [
    gstreamer
    gst-plugins-good
    gst-plugins-ugly
    gst-plugins-base
    gst-plugins-bad
  ]);

  propagatedBuildInputs = with python3Packages; [
    distro
    mutagen
    peewee
    pygobject3
    pytz
    requests
  ];

  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  postFixup = ''
    ln -s $out/bin/com.github.geigi.cozy $out/bin/cozy
  '';

  dontWrapGApps = true;
  pyproject = false; # built with meson

  meta = {
    description = "Modern audio book player for Linux";
    homepage = "https://cozy.geigi.de/";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      makefu
      aleksana
    ];

    platforms = lib.platforms.linux;
    mainProgram = "com.github.geigi.cozy";
  };
})
