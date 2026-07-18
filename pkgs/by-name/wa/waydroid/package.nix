{
  lib,
  fetchFromGitHub,
  dnsmasq,
  gawk,
  getent,
  gobject-introspection,
  gtk3,
  iproute2,
  iptables,
  kmod,
  lxc,
  nftables,
  nix-update-script,
  python3Packages,
  runtimeShell,
  util-linux,
  wl-clipboard,
  wrapGAppsHook3,
  withNftables ? false,
}:

python3Packages.buildPythonApplication rec {
  pname = "waydroid";
  version = "1.6.3";

  src = fetchFromGitHub {
    owner = "waydroid";
    repo = "waydroid";
    tag = version;
    hash = "sha256-1YYNSqIW+0vkCRZ+vemqu0CXhU6aOGvpMzdswvlAc84=";
  };

  nativeBuildInputs = [
    gobject-introspection
    wrapGAppsHook3
  ];

  buildInputs = [
    gtk3
  ];

  propagatedBuildInputs = with python3Packages; [
    dbus-python
    gbinder-python
    pyclip
    pygobject3
  ];

  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")

    patchShebangs --host $out/lib/waydroid/data/scripts
    wrapProgram $out/lib/waydroid/data/scripts/waydroid-net.sh \
      --prefix PATH ":" ${
        lib.makeBinPath [
          dnsmasq
          getent
          iproute2
          (if withNftables then nftables else iptables)
        ]
      }

    wrapPythonProgramsIn $out/lib/waydroid/ "${
      lib.concatStringsSep " " (
        [
          "$out"
        ]
        ++ propagatedBuildInputs
        ++ [
          gawk
          kmod
          lxc
          util-linux
          wl-clipboard
        ]
      )
    }"

    substituteInPlace $out/lib/waydroid/tools/helpers/run.py $out/lib/waydroid/tools/helpers/lxc.py \
      --replace-fail '"sh"' '"${runtimeShell}"'
  '';

  dontUsePipInstall = true;
  dontUseSetuptoolsBuild = true;
  dontWrapGApps = true;
  dontWrapPythonPrograms = true;

  installFlags = [
    "PREFIX=${placeholder "out"}"
    "USE_SYSTEMD=0"
    "SYSCONFDIR=${placeholder "out"}/etc"
  ]
  ++ lib.optional withNftables "USE_NFTABLES=1";

  pyproject = false;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Container-based approach to boot a full Android system on a regular GNU/Linux system";
    homepage = "https://github.com/waydroid/waydroid";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ bot-wxt1221 ];
    platforms = lib.platforms.linux;
    mainProgram = "waydroid";
  };
}
