{
  lib,
  fetchFromGitHub,
  pkg-config,
  rustPlatform,
  udev,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "framework-tool";
  version = "0.6.5";

  src = fetchFromGitHub {
    owner = "FrameworkComputer";
    repo = "framework-system";
    tag = "v${finalAttrs.version}";
    hash = "sha256-criNeQcbMAWA8q27GClzCncbcj/zhD7yJylQnnFKMS4=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ udev ];
  cargoHash = "sha256-sMhH/Qzc2Pf+hnKcCEmw37s8rLniqFnfZ72ptG8APOk=";

  meta = {
    description = "Swiss army knife for Framework laptops";
    homepage = "https://github.com/FrameworkComputer/framework-system";
    license = lib.licenses.bsd3;

    maintainers = with lib.maintainers; [
      nickcao
      kloenk
      johnazoidberg
    ];

    platforms = [ "x86_64-linux" ];
    mainProgram = "framework_tool";
  };
})
