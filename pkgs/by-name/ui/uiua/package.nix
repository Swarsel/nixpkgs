{
  lib,
  stdenv,
  fetchFromGitHub,
  alsa-lib,
  libGL,
  libffi,
  libx11,
  libxcursor,
  libxi,
  libxkbcommon,
  libxrandr,
  pkg-config,
  runCommand,
  rustPlatform,
  versionCheckHook,
  wayland,
  audioSupport ? true,
  uiua_versionType ? "stable",
  webcamSupport ? false,
  windowSupport ? false,
}:

let
  versionInfo =
    {
      "stable" = import ./stable.nix;
      "unstable" = import ./unstable.nix;
    }
    .${uiua_versionType};
in

rustPlatform.buildRustPackage (finalAttrs: {
  inherit (versionInfo) version cargoHash patches;
  pname = "uiua";

  src = fetchFromGitHub {
    inherit (versionInfo) tag hash;
    owner = "uiua-lang";
    repo = "uiua";
  };

  nativeBuildInputs =
    lib.optionals (webcamSupport || stdenv.hostPlatform.isDarwin) [ rustPlatform.bindgenHook ]
    ++ lib.optionals audioSupport [ pkg-config ];

  buildInputs = [
    libffi
  ] # we force dynamic linking our own libffi below
  ++ lib.optionals (audioSupport && stdenv.hostPlatform.isLinux) [ alsa-lib ];

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  postFixup =
    let
      runtimeDependencies = lib.optionals windowSupport [
        libGL
        libxkbcommon
        wayland
        libx11
        libxcursor
        libxi
        libxrandr
      ];
    in
    lib.optionalString (runtimeDependencies != [ ] && stdenv.hostPlatform.isLinux) ''
      patchelf --add-rpath ${lib.makeLibraryPath runtimeDependencies} $out/bin/uiua
    '';

  buildFeatures = [
    "libffi/system"
  ] # force libffi to be linked dynamically instead of rebuilding it
  ++ lib.optional audioSupport "audio"
  ++ lib.optional webcamSupport "webcam"
  ++ lib.optional windowSupport "window";

  passthru.tests.run =
    runCommand "uiua-test-run" { nativeBuildInputs = [ finalAttrs.finalPackage ]; }
      ''
        echo '&p "Hello, World!"' > test.ua
        diff -U3 --color=auto <(uiua run test.ua) <(echo 'Hello, World!')
        touch $out
      '';

  passthru.updateScript = versionInfo.updateScript;

  meta = {
    description = "Stack-oriented array programming language with a focus on simplicity, beauty, and tacit code";

    longDescription = ''
      Uiua combines the stack-oriented and array-oriented paradigms in a single
      language. Combining these already terse paradigms results in code with a very
      high information density and little syntactic noise.
    '';

    homepage = "https://www.uiua.org/";
    changelog = "https://github.com/uiua-lang/uiua/blob/${finalAttrs.src.rev}/changelog.md";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      cafkafk
      tomasajt
      defelo
    ];

    mainProgram = "uiua";
  };
})
