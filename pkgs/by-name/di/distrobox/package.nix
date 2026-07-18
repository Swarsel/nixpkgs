{
  lib,
  fetchFromGitHub,
  gnugrep,
  makeWrapper,
  nix-update-script,
  stdenvNoCC,
  testers,
  wget,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "distrobox";
  version = "1.8.2.5";

  src = fetchFromGitHub {
    owner = "89luca89";
    repo = "distrobox";
    tag = finalAttrs.version;
    hash = "sha256-sqMtB5THrspxkapB8eBfb9LNEnghE0UolivOvOEf7cs=";
  };

  patches = [
    # https://github.com/89luca89/distrobox/issues/408
    ./relative-default-icon.patch
  ];

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    ./install -P $out

    runHook postInstall
  '';

  # https://github.com/89luca89/distrobox/issues/407
  postFixup = ''
    wrapProgram "$out/bin/distrobox-generate-entry" \
      --prefix PATH ":" ${lib.makeBinPath [ wget ]}

    mv "$out/bin/${finalAttrs.meta.mainProgram}" "$out/bin/.${finalAttrs.meta.mainProgram}-wrapped"
    makeWrapper "${stdenvNoCC.shell}" "$out/bin/${finalAttrs.meta.mainProgram}" \
      --prefix PATH ":" "${lib.makeBinPath [ gnugrep ]}" \
      --add-flags "-c 'source \"$out/bin/.${finalAttrs.meta.mainProgram}-wrapped\"' \"\$0\""

    mkdir -p $out/share/distrobox
    echo 'container_additional_volumes="/nix:/nix"' > $out/share/distrobox/distrobox.conf
  '';

  dontBuild = true;
  dontConfigure = true;

  passthru = {
    tests.version = testers.testVersion {
      package = finalAttrs.finalPackage;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Wrapper around podman or docker to create and start containers";

    longDescription = ''
      Use any linux distribution inside your terminal. Enable both backward and
      forward compatibility with software and freedom to use whatever distribution
      you’re more comfortable with
    '';

    homepage = "https://distrobox.it/";
    license = lib.licenses.gpl3Only;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "distrobox";
  };
})
