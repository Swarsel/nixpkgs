{
  lib,
  stdenv,
  fetchFromGitHub,
  libiconv,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "fastmod";
  version = "0.4.4";

  src = fetchFromGitHub {
    owner = "facebookincubator";
    repo = "fastmod";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-A/3vzfwaStoQ9gdNM8yjmL2J/pQjj6yb68WThiTF+1E=";
  };

  buildInputs = lib.optionals stdenv.hostPlatform.isDarwin [
    libiconv
  ];

  cargoHash = "sha256-GpV7F0TQyIRowY8LqLTVuwJcRYyyu055+g7BmxT4TMQ=";

  meta = {
    description = "Utility that makes sweeping changes to large, shared code bases";
    homepage = "https://github.com/facebookincubator/fastmod";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ jduan ];
    mainProgram = "fastmod";
  };
})
