class Conection < ApplicationRecord
  belongs_to :user, optional: true
  scope :find_follow, -> (sender_id, recipient_id) { where(sender_id: sender_id,
  	recipient_id: recipient_id).or(Conection.where(sender_id: recipient_id, recipient_id: sender_id))}
  scope :find_want_follow, ->(recipient_id) {where(recipient_id: recipient_id, status: false)}
  scope :find_followed, -> (user_id) { where(sender_id: user_id, status: true).or(Conection.where(recipient_id: user_id, status: true))}
end
