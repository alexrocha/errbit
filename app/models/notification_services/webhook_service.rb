class NotificationServices::WebhookService < NotificationService
  LABEL = "webhook"
  FIELDS = [
    [:api_token, {
      placeholder: 'URL to receive a POST request when an error occurs',
      label:       'URL'
    }]
  ]

  def check_params
    if FIELDS.detect { |f| self[f[0]].blank? }
      errors.add :base, 'You must specify the URL'
    end
  end

  def load_message_webhook(problem)
    case ENV['WEBHOOK_TYPE']
    when 'MS-TEAMS'
      teams_message_for_webhook(problem)
    else
      message_for_webhook(problem)
    end
  end

  def message_for_webhook(problem)
    { problem: { url: problem.url }.merge!(problem.as_json) }
  end

  def teams_message_for_webhook(problem)
    {
      title: "Erro em #{problem.app.name} 😥", text: "Erro: **#{problem.message}**  
      Onde: **#{problem.where}**  
      [Detalhes](#{problem.url})"
    }
  end

  def create_notification(problem)
    HTTParty.post(api_token, headers: { 'Content-Type' => 'application/json', 'User-Agent' => 'Errbit' }, body: load_message_webhook(problem).to_json)
  end
end
