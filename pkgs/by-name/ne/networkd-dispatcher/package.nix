{
  lib,
  stdenv,
  fetchFromGitLab,
  asciidoc,
  fetchpatch,
  installShellFiles,
  iw,
  python3,
  python3Packages,
  wrapGAppsNoGuiHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "networkd-dispatcher";
  version = "2.2.4";

  src = fetchFromGitLab {
    owner = "craftyguy";
    repo = "networkd-dispatcher";
    rev = finalAttrs.version;
    hash = "sha256-yO9/HlUkaQmW/n9N3vboHw//YMzBjxIHA2zAxgZNEv0=";
  };

  patches = [
    # Support rule files in NixOS store paths. Required for the networkd-dispatcher
    # module to work
    ./support_nix_store_path.patch

    # Fixes: networkd-dispatcher.service: Got notification message from PID XXXX, but reception only permitted for main PID XXXX
    (fetchpatch {
      hash = "sha256-RAoCSmZCjTXxVKesatWjiePY4xECGn5pwvOOV0clL+Q=";
      url = "https://gitlab.com/craftyguy/networkd-dispatcher/-/commit/4796368d88da516fafda321d8565ae8ccf465120.patch";
    })
  ];

  postPatch = ''
    # Fix paths in systemd unit file
    substituteInPlace networkd-dispatcher.service \
      --replace-fail "/usr/bin/networkd-dispatcher" "$out/bin/networkd-dispatcher"
    # Remove conditions on existing rules path
    sed -i '/ConditionPathExistsGlob/g' networkd-dispatcher.service
  '';

  nativeBuildInputs = [
    asciidoc # for a2x
    installShellFiles
    wrapGAppsNoGuiHook
  ];

  buildInputs = [
    (python3.withPackages (ps: [
      ps.dbus-python
      ps.pygobject3
    ]))
  ];

  doCheck = true;

  checkInputs = with python3Packages; [
    mock
    pytestCheckHook
  ];

  installPhase = ''
    runHook preInstall
    install -D -m755 -t $out/bin networkd-dispatcher
    patchShebangs --host $out/bin/networkd-dispatcher
    install -Dm644 networkd-dispatcher.service $out/lib/systemd/system/networkd-dispatcher.service
    install -Dm644 networkd-dispatcher.conf $out/etc/conf.d/networkd-dispatcher.conf
    installManPage networkd-dispatcher.8
    runHook postInstall
  '';

  preFixup = ''
    gappsWrapperArgs+=("--prefix" "PATH" ":" "${lib.makeBinPath [ iw ]}")
  '';

  meta = {
    description = "Dispatcher service for systemd-networkd connection status changes";
    homepage = "https://gitlab.com/craftyguy/networkd-dispatcher";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ onny ];
    platforms = lib.platforms.linux;
    mainProgram = "networkd-dispatcher";
  };
})
