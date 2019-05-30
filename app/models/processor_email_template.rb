class ProcessorEmailTemplate < ApplicationRecord
  belongs_to :processor

  enum email_type: [:one_off_approved, :one_off_fail, :recurring_start, :recurring_fail, :one_off_pending, :one_off_pending_rejected]

  validates_presence_of :processor, :html, :sender_name, :sender_email, :subject, :email_type
  validate :can_render?

  def can_render?
    return unless html.present? && subject.present?

    begin
      render_subject(first_name: "Test", last_name: "Ipop")
    rescue Mustache::Parser::SyntaxError => e
      errors.add(:subject, "Error in Subject template: #{e.message}")
    end

    begin
      render_html(first_name: "Test", last_name: "Ipop")
    rescue Mustache::Parser::SyntaxError => e
      errors.add(:html, "Error in HTML template: #{e.message}")
    end
  end

  def render_subject(vars)
    Mustache.render(subject, vars)
  end

  def render_html(vars)
    Mustache.render(html, vars)
  end
end
