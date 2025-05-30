class Recipe < ApplicationRecord

  after_save :set_content, if: -> { saved_change_to_name? || saved_change_to_ingredients? }

  def content
    if super.blank?
      set_content
    else
      super
    end
  end


  private

  def set_content
    client = OpenAI::Client.new
    chatgpt_response = client.chat(parameters: {
      "model": "gpt-4o-mini",
      messages: [{
        role: "user",
        content: "Give me a simple recipe for #{self.name} with the ingredients #{self.ingredients}. Give me only the text of the recipe, without any of your own answer like 'Here is a simple recipe'."
      }]
    })
    new_content = chatgpt_response["choices"][0]["message"]["content"]

    self.update(content: new_content)
    return new_content
  end
end
