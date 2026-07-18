{
  lib,
  stdenv,
  fetchFromGitHub,
  gawk,
  installShellFiles,
  makeWrapper,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "lynis";
  version = "3.1.7";

  src = fetchFromGitHub {
    owner = "CISOfy";
    repo = "lynis";
    tag = finalAttrs.version;
    hash = "sha256-trD0/t7f3JChlv9aLyeGlieAEcxfUl4iPfubfpieoVA=";
  };

  postPatch = ''
    grep -rl '/usr/local/lynis' ./ | xargs sed -i "s@/usr/local/lynis@$out/share/lynis@g"
  '';

  nativeBuildInputs = [
    installShellFiles
    makeWrapper
  ];

  installPhase = ''
    install -d $out/bin $out/share/lynis
    install -Dm555 -t $out/libexec lynis
    cp -r include db default.prf plugins $out/share/lynis/
    makeWrapper "$out/libexec/lynis" "$out/bin/lynis" \
      --prefix PATH : ${lib.makeBinPath [ gawk ]}

    installManPage lynis.8
    installShellCompletion --bash --name lynis.bash \
      extras/bash_completion.d/lynis
  '';

  meta = {
    description = "Security auditing tool for Linux, macOS, and UNIX-based systems";
    homepage = "https://cisofy.com/lynis/";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ ryneeverett ];
    platforms = lib.platforms.unix;
    mainProgram = "lynis";
  };
})
