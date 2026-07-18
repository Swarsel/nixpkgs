{
  lib,
  stdenv,
  fetchFromGitHub,
  bubblewrap,
  gdk-pixbuf,
  gettext,
  gitUpdater,
  glib,
  gobject-introspection,
  gtk3,
  meson,
  ninja,
  polkit,
  python3,
  wrapGAppsHook3,
  xapp,
  xapp-symbolic-icons,
}:

let
  pythonEnv = python3.withPackages (
    pp:
    with pp;
    [
      grpcio-tools
      protobuf
      pygobject3
      setproctitle
      python-xapp
      zeroconf
      grpcio
      cryptography
      pynacl
      netifaces
      netaddr
      ifaddr
      qrcode
    ]
    ++ qrcode.optional-dependencies.pil
  );
in
stdenv.mkDerivation (finalAttrs: {
  pname = "warpinator";
  version = "2.0.4";

  src = fetchFromGitHub {
    owner = "linuxmint";
    repo = "warpinator";
    rev = finalAttrs.version;
    hash = "sha256-JMUa2EFmdEu0n+iha4N+0HRYoOvf6M9ImH/j7eOAi7Y=";
  };

  postPatch = ''
    chmod +x install-scripts/*
    patchShebangs .

    find . -type f -exec sed -i \
      -e s,/usr/libexec/warpinator,$out/libexec/warpinator,g \
      {} +

    # We make bubblewrap mode always available since
    # landlock mode is not supported in old kernels.
    substituteInPlace src/warpinator-launch.py \
      --replace-fail '"/usr/bin/python3"' '"${pythonEnv.interpreter}"' \
      --replace-fail "/usr/bin/bwrap" "${bubblewrap}/bin/bwrap" \
      --replace-fail 'GLib.find_program_in_path("bwrap")' "True"
  '';

  nativeBuildInputs = [
    meson
    ninja
    gobject-introspection
    wrapGAppsHook3
    gettext
    polkit # for its gettext
  ];

  buildInputs = [
    glib
    gtk3
    gdk-pixbuf
    pythonEnv
    xapp
  ];

  mesonFlags = [
    "-Dbundle-grpc=false"
    "-Dbundle-zeroconf=false"
  ];

  preFixup = ''
    gappsWrapperArgs+=(
      --prefix XDG_DATA_DIRS : "${lib.makeSearchPath "share" [ xapp-symbolic-icons ]}"
    )
  '';

  passthru.updateScript = gitUpdater {
    ignoredVersions = "^master.*";
  };

  meta = {
    description = "Share files across the LAN";
    homepage = "https://github.com/linuxmint/warpinator";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    teams = [ lib.teams.cinnamon ];
  };
})
