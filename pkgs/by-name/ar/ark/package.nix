{
  lib,
  fetchFromGitHub,
  R,
  cmake,
  makeBinaryWrapper,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "ark";
  version = "0.1.252";

  src = fetchFromGitHub {
    owner = "posit-dev";
    repo = "ark";
    rev = finalAttrs.version;
    hash = "sha256-AI8i15UMI+KSmweXkS/UYITZBOEDx/knjpK9SA2M+Ns=";
  };

  # The amalthea crate bundles libzmq via the zeromq-src crate, which builds it
  # with CMake.
  nativeBuildInputs = [
    cmake
    makeBinaryWrapper
  ];

  cargoHash = "sha256-z9l0dgmZO6f63I/2pms4VMXMxO/9SAZSq1OFubGHIpw=";
  # Tests require a running R installation and network access.
  doCheck = false;

  # Ark loads R dynamically at runtime, locating it via `R_HOME` or by running
  # `R RHOME`. Put R on PATH so the kernel works out of the box.
  postInstall = ''
    wrapProgram $out/bin/ark \
      --suffix PATH : ${lib.makeBinPath [ R ]}
  '';

  __structuredAttrs = true;

  # Only build the `ark` binary, not the whole workspace's test/dev crates.
  cargoBuildFlags = [
    "--package"
    "ark"
  ];

  meta = {
    description = "R kernel for Jupyter applications, powering Positron's R support";
    homepage = "https://github.com/posit-dev/ark";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ thomasjm ];
    platforms = lib.platforms.unix;
    mainProgram = "ark";
  };
})
