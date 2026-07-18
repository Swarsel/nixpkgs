{
  libdisplay-info,
  libgbm,
  libinput,
  libxkbcommon,
  lua5_4,
  pinnacle-src,
  pkg-config,
  protobuf,
  rustPlatform,
  seatd,
}:
args:
rustPlatform.buildRustPackage (
  (removeAttrs args [
    "nativeBuildInputs"
    "buildInputs"
  ])
  // {
    nativeBuildInputs = (args.nativeBuildInputs or [ ]) ++ [
      protobuf
      pkg-config
    ];

    buildInputs = (args.buildInputs or [ ]) ++ [
      seatd.dev
      libxkbcommon
      libinput
      lua5_4
      libdisplay-info
      libgbm
    ];

    PINNACLE_PROTOBUF_API_DEFS = "${pinnacle-src}/api/protobuf";
    PINNACLE_PROTOBUF_SNOWCAP_API_DEFS = "${pinnacle-src}/snowcap/api/protobuf";
  }
)
