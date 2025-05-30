class Recipe < ApplicationRecord


  def content
    Rails.cache.fetch("#{cache_key_with_version}/content") do
      client = OpenAI::Client.new
      chatgpt_response = client.chat(parameters: {
        "model": "gpt-4o-mini",
        messages: [{
          role: "user",
          content: "Give me a simple recipe for #{self.name} with the ingredients #{self.ingredients}. Give me only the text of the recipe, without any of your own answer like 'Here is a simple recipe'."
        }]
      })
      chatgpt_response["choices"][0]["message"]["content"]
    end
  end
end
