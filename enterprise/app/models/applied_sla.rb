# == Schema Information
#
# Table name: applied_slas
#
#  id              :bigint           not null, primary key
#  sla_status      :integer          default("active")
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  account_id      :bigint           not null
#  conversation_id :bigint           not null
#  sla_policy_id   :bigint           not null
#
# Indexes
#
#  index_applied_slas_on_account_id                       (account_id)
#  index_applied_slas_on_account_sla_policy_conversation  (account_id,sla_policy_id,conversation_id) UNIQUE
#  index_applied_slas_on_conversation_id                  (conversation_id)
#  index_applied_slas_on_sla_policy_id                    (sla_policy_id)
#
class AppliedSla < ApplicationRecord
  belongs_to :account
  belongs_to :sla_policy
  belongs_to :conversation

  has_many :sla_events, dependent: :destroy

  validates :account_id, uniqueness: { scope: %i[sla_policy_id conversation_id] }
  before_validation :ensure_account_id

  enum sla_status: { active: 0, hit: 1, missed: 2 }

  scope :filter_by_created_at, ->(range) { where(created_at: range) if range.present? }
  scope :filter_by_sla_policy_id, ->(sla_policy_id) { where(sla_policy_id: sla_policy_id) if sla_policy_id.present? }
  scope :filter_by_assigned_agent_id, ->(user_ids) { joins(:conversation).where(conversations: { assigned_agent_id: user_ids }) if user_ids.present? }
  scope :filter_by_inbox_id, ->(inbox_id) { joins(:conversation).where(conversations: { inbox_id: inbox_id }) if inbox_id.present? }
  scope :filter_by_team_id, ->(team_id) { joins(:conversation).where(conversations: { team_id: team_id }) if team_id.present? }
  private

  def ensure_account_id
    self.account_id ||= sla_policy&.account_id
  end
end
