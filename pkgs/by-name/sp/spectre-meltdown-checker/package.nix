{
  lib,
  stdenv,
  fetchFromGitHub,
  binutils-unwrapped,
  coreutils,
  gitUpdater,
  makeBinaryWrapper,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "spectre-meltdown-checker";
  version = "26.36.0602723";

  src = fetchFromGitHub {
    owner = "speed47";
    repo = "spectre-meltdown-checker";
    tag = "v${finalAttrs.version}";
    hash = "sha256-UPpArgFbz2nce63fS6AScitHeL8/XlA0aInyeRxN9ZM=";
  };

  nativeBuildInputs = [ makeBinaryWrapper ];

  installPhase = ''
    runHook preInstall

    install -Dm755 spectre-meltdown-checker.sh $out/bin/spectre-meltdown-checker
    wrapProgram $out/bin/spectre-meltdown-checker \
      --prefix PATH : ${lib.makeBinPath [ binutils-unwrapped ]}

    runHook postInstall
  '';

  prePatch = ''
    substituteInPlace spectre-meltdown-checker.sh \
      --replace-fail /bin/echo ${coreutils}/bin/echo
  '';

  passthru.updateScript = gitUpdater { };

  meta = {
    description = "Spectre & Meltdown vulnerability/mitigation checker for Linux";
    homepage = "https://github.com/speed47/spectre-meltdown-checker";
    changelog = "https://github.com/speed47/spectre-meltdown-checker/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.gpl3Only;
    maintainers = [ lib.maintainers.dotlambda ];
    platforms = lib.platforms.linux;
    mainProgram = "spectre-meltdown-checker";
  };
})
