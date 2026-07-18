{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  expat,
  fontconfig,
  freetype,
  installShellFiles,
  libGL,
  libx11,
  libxcb,
  libxcursor,
  libxi,
  libxkbcommon,
  libxxf86vm,
  makeWrapper,
  ncurses,
  nix-update-script,
  nixosTests,
  pkg-config,
  python3,
  rustPlatform,
  scdoc,
  versionCheckHook,
  wayland,
  xdg-utils,
  withGraphics ? false,
}:
let
  rpathLibs = [
    expat
    fontconfig
    freetype
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    libGL
    libx11
    libxcursor
    libxi
    libxxf86vm
    libxcb
    libxkbcommon
    wayland
  ];
in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "alacritty${lib.optionalString withGraphics "-graphics"}";
  version = "0.17.0";

  src =
    # by default we want the official package
    if !withGraphics then
      fetchFromGitHub {
        owner = "alacritty";
        repo = "alacritty";
        tag = "v${finalAttrs.version}";
        hash = "sha256-iZtCH2DrSs6o3AG2koI2TyC3116aMlawHFkCd0TYhas=";
      }
    # optionally we want to build the sixels feature fork
    else
      fetchFromGitHub {
        owner = "ayosec";
        repo = "alacritty";
        tag = "v${finalAttrs.version}-graphics";
        hash = "sha256-DdiioNKMVg9u4E4h7AysvaGJ6ys36ykTyJgjHWjIjjY=";
      };

  outputs = [
    "out"
    "terminfo"
  ];

  postPatch = lib.optionalString stdenv.hostPlatform.isLinux ''
    substituteInPlace alacritty/src/config/ui_config.rs \
      --replace xdg-open ${xdg-utils}/bin/xdg-open
  '';

  nativeBuildInputs = [
    cmake
    installShellFiles
    makeWrapper
    ncurses
    pkg-config
    python3
    scdoc
  ];

  buildInputs = rpathLibs;

  cargoHash =
    if !withGraphics then
      "sha256-BX4PjZXr19SScEZhb0gWkMiJUYq8ByEuVh9RpJSRCHI="
    else
      "sha256-xWW0X4dCgnNMT4T6BNsYmxOOFIK8MIHwUMKVtIHAFYc=";

  checkFlags = [ "--skip=term::test::mock_term" ]; # broken on aarch64

  postInstall =
    (
      if stdenv.hostPlatform.isDarwin then
        ''
          mkdir $out/Applications
          cp -r extra/osx/Alacritty.app $out/Applications
          ln -s $out/bin $out/Applications/Alacritty.app/Contents/MacOS
        ''
      else
        ''
          install -D extra/linux/Alacritty.desktop -t $out/share/applications/
          install -D extra/linux/org.alacritty.Alacritty.appdata.xml -t $out/share/appdata/
          install -D extra/logo/compat/alacritty-term.svg $out/share/icons/hicolor/scalable/apps/Alacritty.svg

          # patchelf generates an ELF that binutils' "strip" doesn't like:
          #    strip: not enough room for program headers, try linking with -N
          # As a workaround, strip manually before running patchelf.
          $STRIP -S $out/bin/alacritty

          patchelf --add-rpath "${lib.makeLibraryPath rpathLibs}" $out/bin/alacritty
        ''
    )
    + ''
      installShellCompletion --zsh extra/completions/_alacritty
      installShellCompletion --bash extra/completions/alacritty.bash
      installShellCompletion --fish extra/completions/alacritty.fish

      install -dm 755 "$out/share/man/man1"
      install -dm 755 "$out/share/man/man5"

      scdoc < extra/man/alacritty.1.scd | gzip -c > $out/share/man/man1/alacritty.1.gz
      scdoc < extra/man/alacritty-msg.1.scd | gzip -c > $out/share/man/man1/alacritty-msg.1.gz
      scdoc < extra/man/alacritty.5.scd | gzip -c > $out/share/man/man5/alacritty.5.gz
      scdoc < extra/man/alacritty-bindings.5.scd | gzip -c > $out/share/man/man5/alacritty-bindings.5.gz

      install -dm 755 "$terminfo/share/terminfo/a/"
      tic -xe alacritty,alacritty-direct -o "$terminfo/share/terminfo" extra/alacritty.info
      mkdir -p $out/nix-support
      echo "$terminfo" >> $out/nix-support/propagated-user-env-packages
    '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  dontPatchELF = true;

  passthru = {
    tests.test = nixosTests.terminal-emulators.alacritty;
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Cross-platform, GPU-accelerated terminal emulator";

    homepage =
      if !withGraphics then
        "https://github.com/alacritty/alacritty"
      else
        "https://github.com/ayosec/alacritty";

    changelog =
      if !withGraphics then
        "https://github.com/alacritty/alacritty/blob/v${finalAttrs.version}/CHANGELOG.md"
      else
        "https://github.com/ayosec/alacritty/blob/v${finalAttrs.version}-graphics/CHANGELOG.md";

    license = lib.licenses.asl20;

    maintainers =
      with lib.maintainers;
      if !withGraphics then
        [
          rvdp
        ]
      else
        [
          afh
        ];

    platforms = lib.platforms.unix;
    mainProgram = "alacritty";
  };
})
