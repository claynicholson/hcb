# frozen_string_literal: true

class AddStripeCardsEnabledToCardGrantSettings < ActiveRecord::Migration[7.2]
  def change
    add_column :card_grant_settings, :stripe_cards_enabled, :boolean, default: true, null: false
  end
end
