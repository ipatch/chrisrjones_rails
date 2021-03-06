# frozen_string_literal: true

class AddConfirmationTokenToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :confirmation_token, :string
    add_column :users, :confirmation_sent_at, :datetime
    add_column :users, :confirmed, :boolean, default: false
  end
end
