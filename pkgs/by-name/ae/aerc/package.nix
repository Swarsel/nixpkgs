{
  lib,
  bashNonInteractive,
  buildGoModule,
  dante,
  fetchFromSourcehut,
  gawk,
  ncurses,
  nix-update-script,
  notmuch,
  python3Packages,
  scdoc,
  versionCheckHook,
  w3m,
  withNotmuch ? true,
}:

buildGoModule (finalAttrs: {
  pname = "aerc";
  version = "0.21.0";

  src = fetchFromSourcehut {
    owner = "~rjarry";
    repo = "aerc";
    rev = finalAttrs.version;
    hash = "sha256-UBXMAIuB0F7gG0dkpEF/3V4QK6FEbQw2ZLGGmRF884I=";
  };

  patches = [ ./runtime-libexec.patch ];

  postPatch = ''
    substituteAllInPlace config/aerc.conf
    substituteAllInPlace config/config.go
    substituteAllInPlace doc/aerc-config.5.scd
    substituteAllInPlace doc/aerc-templates.7.scd

    # Prevent buildGoModule from trying to build this
    rm contrib/linters.go
  '';

  nativeBuildInputs = [
    scdoc
    python3Packages.wrapPython
  ];

  buildInputs = [
    python3Packages.python
    gawk
    bashNonInteractive
  ]
  ++ lib.optional withNotmuch notmuch;

  vendorHash = "sha256-E/DnfiHoDDNNoaNGZC/nvs8DiJ8F2+H2FzxpU7nK+bE=";
  makeFlags = [ "PREFIX=${placeholder "out"}" ];

  installPhase = ''
    runHook preInstall

    make $makeFlags GOFLAGS="$GOFLAGS${lib.optionalString withNotmuch " -tags=notmuch"}" install
    wrapPythonProgramsIn "$out/libexec/" "''${pythonPath[*]}"

    runHook postInstall
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  postFixup = ''
    wrapProgram $out/bin/aerc \
      --prefix PATH : ${lib.makeBinPath [ ncurses ]}
    wrapProgram $out/libexec/aerc/filters/html \
      --prefix PATH : ${
        lib.makeBinPath [
          w3m
          dante
        ]
      }
  '';

  proxyVendor = true;
  pythonPath = [ python3Packages.vobject ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Email client for your terminal";
    homepage = "https://aerc-mail.org/";
    changelog = "https://git.sr.ht/~rjarry/aerc/tree/${finalAttrs.version}/item/CHANGELOG.md";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      defelo
      sikmir
    ];

    platforms = lib.platforms.unix;
    mainProgram = "aerc";
  };
})
