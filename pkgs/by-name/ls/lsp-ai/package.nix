{
  lib,
  fetchFromGitHub,
  cmake,
  gitUpdater,
  oniguruma,
  openssl,
  perl,
  pkg-config,
  rustPlatform,
  zlib,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "lsp-ai";
  version = "0.7.1";

  src = fetchFromGitHub {
    owner = "SilasMarvin";
    repo = "lsp-ai";
    tag = "v${finalAttrs.version}";
    hash = "sha256-mBbaJn4u+Wlu/Y4G4a6YUBWnmN143INAGm0opiAjnIk=";
  };

  nativeBuildInputs = [
    pkg-config
    cmake
    perl
  ];

  buildInputs = [
    oniguruma
    openssl
    zlib
  ];

  cargoHash = "sha256-KR6BmYj3q9w0yGHFq9+l1x989XjiG3mkaZiyDGCYWPA=";
  # use system oniguruma since the bundled one fails to build with gcc15
  env.RUSTONIG_SYSTEM_LIBONIG = 1;

  checkFlags = [
    # These integ tests require an account and network usage to work
    "--skip=transformer_backends::open_ai::test::open_ai_completion_do_generate"
    "--skip=transformer_backends::mistral_fim::test::mistral_fim_do_generate"
    "--skip=transformer_backends::anthropic::test::anthropic_chat_do_generate"
    "--skip=transformer_backends::open_ai::test::open_ai_chat_do_generate"
    "--skip=transformer_backends::gemini::test::gemini_chat_do_generate"
    "--skip=transformer_backends::ollama::test::ollama_chat_do_generate"
    "--skip=transformer_backends::ollama::test::ollama_completion_do_generate"
    "--skip=embedding_models::ollama::test::ollama_embeding"
    "--skip=transformer_worker::tests::test_do_completion"
    "--skip=transformer_worker::tests::test_do_generate"
    "--skip=memory_backends::vector_store::tests::can_open_document"
    "--skip=memory_backends::vector_store::tests::can_rename_document"
    "--skip=memory_backends::vector_store::tests::can_build_prompt"
    "--skip=memory_backends::vector_store::tests::can_change_document"
    # These integ test require a LLM server to be running over the network
    "--skip=lsp_ai::transformer_worker"
    "--skip=lsp_ai::memory_worker"
    "--skip=test_chat_sequence"
    "--skip=test_completion_action_sequence"
    "--skip=test_chat_completion_sequence"
    "--skip=test_completion_sequence"
    "--skip=test_fim_completion_sequence"
    "--skip=test_refactor_action_sequence"
  ];

  cargoBuildFlags = [ "-p lsp-ai" ];

  passthru.updateScript = gitUpdater {
    rev-prefix = "v";
  };

  meta = {
    description = "Open-source language server that serves as a backend for AI-powered functionality";
    homepage = "https://github.com/SilasMarvin/lsp-ai";
    changelog = "https://github.com/SilasMarvin/lsp-ai/releases/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ projectinitiative ];
    mainProgram = "lsp-ai";
  };
})
