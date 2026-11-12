# frozen_string_literal: true

Jekyll::Hooks.register :documents, :pre_render_chulapa_md do |document, _payload|
  document.data["raw_content"] = document.content.dup
end
