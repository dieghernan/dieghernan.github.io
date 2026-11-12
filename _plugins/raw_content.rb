# frozen_string_literal: true

Jekyll::Hooks.register :documents, :pre_render do |document, _payload|
  document.data["raw_content"] = document.content.dup
end
