require "open-uri"
class Recipe < ApplicationRecord
  has_one_attached :photo

  after_save if: -> { saved_change_to_name? || saved_change_to_ingredients? } do
    set_content
    # set_photo
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
    RecipeContentJob.perform_later(self)
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
