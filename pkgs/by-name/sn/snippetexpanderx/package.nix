{
  lib,
  stdenv,
  at-spi2-atk,
  at-spi2-core,
  dbus,
  gtk3,
  ibus,
  installShellFiles,
  libgee,
  libx11,
  pkg-config,
  scdoc,
  snippetexpanderd,
  vala,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  inherit (snippetexpanderd) src version;
  pname = "snippetexpanderx";

  nativeBuildInputs = [
    pkg-config
    vala
    wrapGAppsHook3
    installShellFiles
    scdoc
  ];

  buildInputs = [
    at-spi2-atk
    at-spi2-core
    dbus
    gtk3
    ibus
    libgee
    libx11
    snippetexpanderd
  ];

  makeFlags = [ "VERSION=${finalAttrs.src.rev}" ];
  # There are no tests.
  doCheck = false;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    install -m555 snippetexpanderx $out/bin/
    installManPage snippetexpanderx.1
    runHook postInstall
  '';

  sourceRoot = "${finalAttrs.src.name}/cmd/snippetexpanderx";

  meta = {
    description = "Your little expandable text snippet helper auto expander daemon";
    homepage = "https://snippetexpander.org";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "snippetexpanderx";
  };
})
