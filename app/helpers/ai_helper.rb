# frozen_string_literal: true

module AiHelper
  # Text-based AI operations
  def ai_chat(prompt, model: nil, **options)
    RailsAi.chat(prompt, model: model, **options)
  end

  def ai_stream(prompt, model: nil, **options, &block)
    RailsAi.stream(prompt, model: model, **options, &block)
  end

  def ai_embed(texts, model: nil, **options)
    RailsAi.embed(texts, model: model, **options)
  end

  # Image generation
  def ai_generate_image(prompt, model: "dall-e-3", size: "1024x1024", **options)
    RailsAi.generate_image(prompt, model: model, size: size, **options)
  end

  def ai_edit_image(image, prompt, **options)
    RailsAi.edit_image(image, prompt, **options)
  end

  def ai_create_variation(image, **options)
    RailsAi.create_variation(image, **options)
  end

  # Video generation
  def ai_generate_video(prompt, model: "sora", duration: 5, **options)
    RailsAi.generate_video(prompt, model: model, duration: duration, **options)
  end

  def ai_edit_video(video, prompt, **options)
    RailsAi.edit_video(video, prompt, **options)
  end

  # Audio generation
  def ai_generate_speech(text, voice: "alloy", **options)
    RailsAi.generate_speech(text, voice: voice, **options)
  end

  def ai_transcribe_audio(audio, **options)
    RailsAi.transcribe_audio(audio, **options)
  end

  # Multimodal analysis
  def ai_analyze_image(image, prompt, **options)
    RailsAi.analyze_image(image, prompt, **options)
  end

  def ai_analyze_video(video, prompt, **options)
    RailsAi.analyze_video(video, prompt, **options)
  end

  # Context-aware AI operations
  def ai_analyze_image_with_context(image, prompt, user_context: {}, window_context: {}, image_context: {}, **options)
    RailsAi.analyze_image_with_context(image, prompt, 
      user_context: user_context, 
      window_context: window_context, 
      image_context: image_context, 
      **options
    )
  end

  def ai_generate_with_context(prompt, user_context: {}, window_context: {}, **options)
    RailsAi.generate_with_context(prompt, 
      user_context: user_context, 
      window_context: window_context, 
      **options
    )
  end

  def ai_generate_image_with_context(prompt, user_context: {}, window_context: {}, **options)
    RailsAi.generate_image_with_context(prompt, 
      user_context: user_context, 
      window_context: window_context, 
      **options
    )
  end

  # Convenience methods for common AI tasks
  def ai_summarize(content, model: nil, **options)
    RailsAi.summarize(content, model: model, **options)
  end

  def ai_translate(content, target_language, **options)
    RailsAi.translate(content, target_language, **options)
  end

  def ai_classify(content, categories, **options)
    RailsAi.classify(content, categories, **options)
  end

  def ai_extract_entities(content, **options)
    RailsAi.extract_entities(content, **options)
  end

  def ai_generate_code(prompt, language: "ruby", **options)
    RailsAi.generate_code(prompt, language: language, **options)
  end

  def ai_explain_code(code, language: "ruby", **options)
    RailsAi.explain_code(code, language: language, **options)
  end

  # Context extraction helpers
  def ai_user_context
    return {} unless respond_to?(:current_user) && current_user

    {
      id: current_user.id,
      email: current_user.respond_to?(:email) ? current_user.email : nil,
      role: current_user.respond_to?(:role) ? current_user.role : 'user',
      created_at: current_user.created_at,
      preferences: extract_user_preferences
    }.compact
  end

  def ai_window_context
    {
      controller: controller_name,
      action: action_name,
      params: params.except('password', 'password_confirmation', 'token', 'secret', 'key'),
      user_agent: request.user_agent,
      referer: request.referer,
      ip_address: request.remote_ip,
      timestamp: Time.current.iso8601
    }
  end

  def ai_image_context(image_data)
    RailsAi::ImageContext.new(image_data).to_h
  end

  # Utility methods
  def ai_stream_id
    @ai_stream_id ||= SecureRandom.uuid
  end

  def ai_redact(text)
    RailsAi::Redactor.call(text)
  end

  def ai_safe_content(text)
    RailsAi::Redactor.call(text)
  end

  private

  def extract_user_preferences
    return {} unless current_user.respond_to?(:preferences)

    case current_user.preferences
    when Hash
      current_user.preferences
    when String
      JSON.parse(current_user.preferences) rescue {}
    else
      {}
    end
  end
end
