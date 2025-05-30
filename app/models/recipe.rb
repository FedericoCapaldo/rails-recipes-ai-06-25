require "open-uri"
class Recipe < ApplicationRecord
  has_one_attached :photo

  after_save if: -> { saved_change_to_name? || saved_change_to_ingredients? } do
    set_content
    set_photo
  end


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

  def set_photo
    client = OpenAI::Client.new
    chatgpt_response = client.images.generate(parameters: {
      prompt: "A recipe image of #{self.name}", size: "256x256"
    })

    new_image_url = chatgpt_response["data"][0]["url"]
    new_image_file =  URI.parse(new_image_url).open

    photo.purge if photo.attached?
    photo.attach(io: new_image_file, filename: "ai_generated_image.png", content_type: "image/png")
    return photo
  end
end
