{
  lib,
  stdenv,
  cmake,
  darwinVersionInputs,
  moveBuildTree,
  ninja,
  perl,
  srcs,
  patches ? [ ],
}:

args:

let
  inherit (args) pname;
  version = args.version or srcs.${pname}.version;
  src = args.src or srcs.${pname}.src;
in
stdenv.mkDerivation (
  args
  // {
    inherit pname version src;

    outputs =
      args.outputs or [
        "out"
        "dev"
      ];

    patches = args.patches or patches.${pname} or [ ];

    nativeBuildInputs =
      (args.nativeBuildInputs or [ ])
      ++ [
        cmake
        ninja
        perl
      ]
      ++ lib.optionals stdenv.hostPlatform.isDarwin [ moveBuildTree ];

    buildInputs =
      args.buildInputs or [ ] ++ lib.optionals stdenv.hostPlatform.isDarwin darwinVersionInputs;

    propagatedBuildInputs =
      (lib.warnIf (args ? qtInputs) "qt6.qtModule's qtInputs argument is deprecated" args.qtInputs or [ ])
      ++ (args.propagatedBuildInputs or [ ]);

    cmakeFlags = [
      # be more verbose
      "--log-level=STATUS"
      # don't leak OS version into the final output
      # https://bugreports.qt.io/browse/QTBUG-136060
      "-DCMAKE_SYSTEM_VERSION="
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      "-DQT_NO_XCODE_MIN_VERSION_CHECK=ON"
      # This is only used for the min version check, which we disabled above.
      # When this variable is not set, cmake tries to execute xcodebuild
      # to query the version.
      "-DQT_INTERNAL_XCODE_VERSION=0.1"
    ]
    ++ args.cmakeFlags or [ ];

    dontWrapQtApps = args.dontWrapQtApps or true;
    moveToDev = false;
    separateDebugInfo = args.separateDebugInfo or true;
  }
)
// {
  meta =

    let
      pos = builtins.unsafeGetAttrPos "pname" args;
    in
    {
      description = "Cross-platform application framework for C++";
      homepage = "https://www.qt.io/";

      license = with lib.licenses; [
        fdl13Plus
        gpl2Plus
        lgpl21Plus
        lgpl3Plus
      ];

      maintainers = with lib.maintainers; [
        nickcao
      ];

      platforms = lib.platforms.unix;
      position = "${pos.file}:${toString pos.line}";
    }
    // (args.meta or { });
}
