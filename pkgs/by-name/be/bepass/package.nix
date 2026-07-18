{
  lib,
  fetchFromGitHub,
  buildGoModule,
  glfw,
  libxcursor,
  libxft,
  libxi,
  libxinerama,
  libxrandr,
  libxxf86vm,
  pkg-config,
  xinput,
  enableGUI ? false, # upstream working in progress
}:
buildGoModule (finalAttrs: {
  pname = "bepass";
  version = "1.6.2";

  src = fetchFromGitHub {
    owner = "bepass-org";
    repo = "bepass";
    rev = "v${finalAttrs.version}";
    hash = "sha256-ruOhPWNs1WWM3r6X+6ch0HoDCu/a+IkBQiCr0Wh6yS8=";
  };

  nativeBuildInputs = lib.optionals enableGUI [ pkg-config ];

  buildInputs = lib.optionals enableGUI [
    glfw
    libxft
    libxcursor
    libxrandr
    libxinerama
    libxi
    xinput
    libxxf86vm
  ];

  vendorHash = "sha256-Juie/Hq3i6rvAK19x6ah3SCQJL0uCrmV9gvzHih3crY=";

  postInstall = ''
    mv $out/bin/cli $out/bin/bepass
  '';

  ldflags = [
    "-s"
    "-w"
  ];

  proxyVendor = true;

  subPackages = [
    "cmd/cli"
  ];

  meta = {
    description = "Simple DPI bypass tool written in go";
    homepage = "https://github.com/bepass-org/bepass";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ oluceps ];
    mainProgram = "bepass";
    broken = enableGUI;
  };
})
