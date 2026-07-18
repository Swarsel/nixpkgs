{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  daemonize,
  dbus-python,
  glib,
  gobject-introspection,
  gtk3,
  libnotify,
  notify2,
  pygobject3,
  pyudev,
  setproctitle,
  setuptools,
  wrapGAppsNoGuiHook,
}:

let
  common = import ./common.nix { inherit lib fetchFromGitHub; };
in
buildPythonPackage (
  common
  // {
    pname = "openrazer-daemon";

    outputs = [
      "out"
      "man"
    ];

    postPatch = ''
      substituteInPlace openrazer_daemon/daemon.py \
        --replace-fail "plugdev" "openrazer"
      patchShebangs run_openrazer_daemon.py
      substituteInPlace run_openrazer_daemon.py \
        --replace-fail "/usr/share" "$out/share"
    '';

    nativeBuildInputs = [
      setuptools
      wrapGAppsNoGuiHook
      gobject-introspection
    ];

    buildInputs = [
      glib
      gtk3
    ];

    # no tests run
    doCheck = false;

    postInstall = ''
      DESTDIR="$out" PREFIX="" make manpages install-resources install-systemd
    '';

    preFixup = ''
      makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
    '';

    dependencies = [
      daemonize
      dbus-python
      pygobject3
      pyudev
      setproctitle
      notify2
      libnotify
    ];

    dontWrapGApps = true;
    sourceRoot = "${common.src.name}/daemon";

    meta = common.meta // {
      description = "Entirely open source user-space daemon that allows you to manage your Razer peripherals on GNU/Linux";
      mainProgram = "openrazer-daemon";
    };
  }
)
