{
  libxscrnsaver,
  mkKdeDerivation,
  pkg-config,
  qtwayland,
}:
mkKdeDerivation {
  pname = "kidletime";

  extraBuildInputs = [
    qtwayland
    libxscrnsaver
  ];

  extraNativeBuildInputs = [ pkg-config ];
}
